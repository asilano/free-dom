require File.dirname(__FILE__) + '/../test_helper'

class PlayerTest < ActiveSupport::TestCase


  should belong_to :game
  should belong_to :user
  should have_many :cards
  should have_many :pending_actions
  should have_one :state
  should have_one :settings

  context "with user defined" do
    setup do
      @user = Factory.create(:user)
      @user.settings.automoat = !@user.settings.automoat
      @user.save!
    end

    should "be able to create player" do
      assert_nothing_raised do
        @ply = @user.players.create
      end

      assert_not_nil @ply
    end


    context "with player created" do
      setup do
        @ply = @user.players.create(:game => @game)
      end

      should validate_uniqueness_of(:user_id).scoped_to('game_id')
      should validate_uniqueness_of(:seat).scoped_to('game_id').allow_nil

      should "have inherited user's settings" do
        assert_equal @user.settings.automoat, @ply.settings.automoat
      end

      should "have divorced settings from user" do
        @ply.settings.automoat = !@ply.settings.automoat
        @ply.settings.save!
        assert_not_equal @user.settings.automoat, @ply.settings.automoat
      end

      should "have state" do
        assert_not_nil @ply.state
      end

      should "have score of 0" do
        assert_equal 0, @ply.score
      end
    end
  end

  context "with game created" do
    setup do
      stub_game(:create_game, :create_players)
      @ply = @ply_alan
    end

    should "have defaulted per-turn fields" do
      assert_nil @ply.actions
      assert_nil @ply.buys
      assert_nil @ply.cash
    end

    should "have no pending actions" do
      assert_equal [], @ply.pending_actions
    end

    should "have no cards" do
      assert_equal [], @ply.cards
    end

    should "gain correct cards when starting game" do
      qshuffle([[9,8,7,0,1,2,3,4,5,6], /player\.rb.*start_game/])
      @ply.start_game
      expect = ["BasicCards::Estate"] * 3 + ["BasicCards::Copper"] * 7
      assert_equal expect, @ply.cards.map(&:type)
      assert_equal expect[0..4], @ply.cards.hand.map(&:type)
      assert_equal expect[5..9], @ply.cards.deck.map(&:type)
    end

    context "with game started" do
      setup do
        qshuffle([[9,8,7,0,1,2,3,4,5,6], /player\.rb.*start_game/])
        stub_game(:start_game)
        @ply.reload
      end

      context ", non-turn players" do
        setup do
          @ply = @ply_bob
        end

        should "have defaulted per-turn fields" do
          assert_nil @ply.actions
          assert_nil @ply.buys
          assert_nil @ply.cash
        end

        should "have no pending actions" do
          assert_equal [], @ply.pending_actions
        end
      end

      context ", the turn player" do
        should "have inited per-turn fields" do
          assert_equal 1, @ply.actions
          assert_equal 1, @ply.buys
          assert_equal 0, @ply.cash
        end

        should "have a turn's worth of pending actions" do
          assert_same_elements ["play_action", "buy"], @ply.pending_actions.map(&:expected_action)
        end

        should "be able to play nothing" do
          ctrls = @ply.determine_controls
          assert_equal({:hand => [{:type => :button,
                                   :action => :play_action,
                                   :name => "play_action",
                                   :text => "Play",
                                   :nil_action => "Leave Action Phase",
                                   :cards => [false,false,false,false,false]}]}, strip_pa_id(ctrls))

          assert_equal "OK", @ply.play_action(:nil_action => true)
          assert_equal "#{@ply.name} played no action.", @game.histories(true).last.event
        end

        should "reject buy when waiting to play" do
          assert_match(/Not expecting to Buy/, @ply.buy(:nil_action => true))
        end

        should "autoplay all simple treasures" do
          @ply.pending_actions.active.first.destroy
          rc = @ply.play_treasures(:parent_act => PendingAction.find_by_expected_action("buy"))
          assert_equal "OK", rc
          assert_equal ["BasicCards::Estate"] * 3, @ply.cards(true).hand.map(&:type)
          assert_equal 2, @ply.cash
          assert_equal "#{@ply.name} played Copper, Copper as Treasures. (2 total).", @game.histories(true).last.event
        end

        context "waiting to buy" do
          setup do
            @ply.pending_actions.active.first.destroy
            @game.pending_actions(true).active.unowned.first.destroy
            @ply.play_treasures(:parent_act => PendingAction.find_by_expected_action("buy"))
            @ply.pending_actions(true)
          end

          should "be able to buy nothing" do
            ctrls = @ply.determine_controls
            assert_equal({:piles => [{:type => :button,
                                      :action => :buy,
                                      :name => "buy",
                                      :text => "Buy",
                                      :nil_action => "Buy no more",
                                      :piles => [true, false, false, true, false, false, true,
                                          true] + [false] * 9}]}, strip_pa_id(ctrls))
            assert_equal "OK", @ply.buy(:nil_action => true)
            assert_equal "#{@ply.name} bought nothing.", @game.histories(true).last.event
          end

          should "reject play_action when waiting to buy" do
            assert_match(/Not expecting an Action/, @ply.play_action(:nil_action => true))
          end

          should "be able to buy" do
            assert_equal "OK", @ply.buy(:pile_index => 7) # Buy a Moat
            assert_match(/bought Moat/, @game.histories(true).last.event)
            assert_match(/^player_gain.*#{@ply.id}/, @game.pending_actions(true).active.unowned.expected_action)
            assert_equal [], @ply.pending_actions(true).active
          end

          should "reject buy of a non-existant pile" do
            assert_match(/out of range/, @ply.buy(:pile_index => 1000))
            assert_equal "buy", @ply.pending_actions(true).active.first.expected_action
          end

          should "reject buy of a too-expensive pile" do
            assert_match(/too expensive/, @ply.buy(:pile_index => 1))  # Duchy
            assert_equal "buy", @ply.pending_actions(true).active.first.expected_action
          end

          should "reject buy of empty pile" do
            BaseGame::Moat.update_all(:pile_id => nil)
            assert_match(/is empty/, @ply.buy(:pile_index => 7))  # Moat
            assert_equal "buy", @ply.pending_actions(true).active.first.expected_action
          end
        end

        should "be able to gain from a pile" do
          pile = @game.piles.find_by_card_type("BasicCards::Curse")
          prev_in_pile = pile.cards.count
          @ply.gain(:pile => pile.id)
          assert_equal prev_in_pile - 1, pile.cards(true).count
          assert_equal "BasicCards::Curse", @ply.cards.in_discard[0][:type]
        end

        context "with all actions destroyed" do
          setup do
            @game.pending_actions.destroy_all
          end

          should "handle end turn" do
            assert_equal "OK", @ply.end_turn(:parent_act => nil)
            patt = <<EOF
---
>
  exp_re: /^player_next_turn.*#{@ply.id}$/
  ply_id:
  kids:
  >
    exp_re: /^player_draw.*#{@ply.id}$/
    ply_id:
    kids:
    >
      exp_re: /^player_clean_up.*#{@ply.id}$/
      ply_id:
      kids:
EOF
            assert_pend_acts_like(patt, @game.pending_actions(true))

            @ply.clean_up(:parent_act => nil)
            assert_equal [], @ply.cards(true).hand
            assert_equal(["BasicCards::Estate"] * 3 + ["BasicCards::Copper"] * 2, @ply.cards(true).in_discard.map(&:type))

            @ply.draw_hand(:parent_act => nil)
            assert_equal(["BasicCards::Copper"] * 5, @ply.cards(true).hand.map(&:type))
          end

          should "set up next turn" do
            assert_equal "OK", @ply.next_turn(:parent_act => nil)
            @ply.reload
            assert_nil @ply.actions
            assert_nil @ply.buys
            assert_nil @ply.cash
            assert_equal [], @ply.pending_actions(true)
            pnext = @ply.next_player
            assert_equal 1, pnext.actions
            assert_equal 1, pnext.buys
            assert_equal 0, pnext.cash

            patt = <<EOF
---
>
  exp_re: /^player_end_turn.*#{pnext.id}$/
  ply_id:
  kids:
  >
    exp_re: /^buy/
    ply_id: #{pnext.id}
    kids:
    >
      exp_re: /^player_play_treasures.*#{pnext.id}$/
      ply_id:
      kids:
      >
        exp_re: /^play_action/
        ply_id: #{pnext.id}
        kids:
EOF
            assert_pend_acts_like(patt, @game.pending_actions(true))
          end
        end

        should "gain actions" do
          @ply.add_actions(2, @ply.pending_actions.active.first)
          pid = @ply.id
          patt = <<EOF
---
>
  exp_re: /^player_end_turn.*#{pid}$/
  ply_id:
  kids:
  >
    exp_re: /^buy/
    ply_id: #{pid}
    kids:
    >
      exp_re: /^player_play_treasures.*#{pid}$/
      ply_id:
      kids:
      >
        exp_re: /^play_action/
        ply_id: #{pid}
        kids:
        >
          exp_re: /^play_action/
          ply_id: #{pid}
          kids:
          >
            exp_re: /^play_action/
            ply_id: #{pid}
            kids:
EOF
          assert_pend_acts_like(patt, @game.pending_actions(true))
        end

        should "gain buys" do
          assert_equal("play_action", @ply.add_buys(2, @ply.pending_actions.active.first).expected_action)
          pid = @ply.id
          patt = <<EOF
---
>
  exp_re: /^player_end_turn.*#{pid}$/
  ply_id:
  kids:
  >
    exp_re: /^buy/
    ply_id: #{pid}
    kids:
    >
      exp_re: /^buy/
      ply_id: #{pid}
      kids:
      >
        exp_re: /^buy/
        ply_id: #{pid}
        kids:
        >
          exp_re: /^player_play_treasures.*#{pid}$/
          ply_id:
          kids:
          >
            exp_re: /^play_action/
            ply_id: #{pid}
            kids:
EOF
          assert_pend_acts_like(patt, @game.pending_actions(true))
        end

        should "add cash" do
          @ply.add_cash(2)
          assert_equal 2, @ply.reload.cash
          @ply.add_cash(70)
          assert_equal 72, @ply.reload.cash
        end
      end

      context "drawing cards" do
        setup do
          new_deck = [BaseGame::Adventurer.new(@ply.cards.deck[0].attributes),
                      Seaside::Bazaar.new(@ply.cards.deck[1].attributes),
                      BaseGame::Chancellor.new(@ply.cards.deck[2].attributes),
                      BasicCards::Duchy.new(@ply.cards.deck[3].attributes),
                      Seaside::Explorer.new(@ply.cards.deck[4].attributes)]
          @ply.cards.deck.each(&:destroy)
          new_deck.each(&:save!)
        end

        should "draw cards" do
          assert_equal ["Adventurer", "Bazaar", "Chancellor"], @ply.draw_cards(3, " for testing")
          assert_same_elements(["BasicCards::Estate"] * 3 + ["BasicCards::Copper"] * 2 + ["BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor"], @ply.cards(true).hand.map(&:type))
          assert_match(/drew \[#{@ply.id}\?Adventurer, Bazaar, Chancellor\|3 cards\] for testing/, @game.histories(true)[-1].event)
        end

        should "handle drawing too many cards" do
          assert_equal(["Adventurer", "Bazaar", "Chancellor",
                        "Duchy", "Explorer"], @ply.draw_cards(7))
          assert_same_elements(["BasicCards::Estate"] * 3 + ["BasicCards::Copper"] * 2 +
                               ["BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor",
                                "BasicCards::Duchy", "Seaside::Explorer"], @ply.cards(true).hand.map(&:type))
          assert_match(/drew \[#{@ply.id}\?Adventurer, Bazaar, Chancellor, Duchy, Explorer\|5 cards\]/, @game.histories(true)[-2].event)
          assert_match(/tried to draw 2 more cards/, @game.histories[-1].event)
        end

        should "handle shuffling-under" do
          @ply.cards.hand.each {|c| c.location = "discard"; c.save!}
          qshuffle([[3,2,4,0,1], /player\.rb.*under/])
          assert_equal(["Adventurer", "Bazaar", "Chancellor",
                        "Duchy", "Explorer",
                        "Copper", "Estate", "Copper"], @ply.draw_cards(8))
          assert_same_elements(["BasicCards::Estate", "BasicCards::Copper", "BasicCards::Copper",
                                "BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor",
                                "BasicCards::Duchy", "Seaside::Explorer"], @ply.cards(true).hand.map(&:type))
          assert_match(/drew \[#{@ply.id}\?Adventurer, Bazaar, Chancellor, Duchy, Explorer\|5 cards\], shuffled.* \[#{@ply.id}\?Copper, Estate, Copper\|3 cards\]/, @game.histories(true)[-1].event)
        end

        should "handle empty deck, shuffle" do
          @ply.cards.deck.each {|c| c.location = "discard"; c.save!}
          qshuffle([[0,1,2,3,4], /player\.rb.*under/])
          assert_equal ["Adventurer", "Bazaar", "Chancellor"], @ply.draw_cards(3, " for testing")
          assert_same_elements(["BasicCards::Estate"] * 3 + ["BasicCards::Copper"] * 2 + ["BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor"], @ply.cards(true).hand.map(&:type))
          assert_match(/drew \[#{@ply.id}\?Adventurer, Bazaar, Chancellor\|3 cards\] for testing/, @game.histories(true)[-1].event)
          assert_match(/#{@ply.name} shuffled their discard pile/, @game.histories[-2].event)
        end
      end

      context "revealing cards" do
        setup do
          new_deck = [BaseGame::Adventurer.new(@ply.cards.deck[0].attributes),
                      Seaside::Bazaar.new(@ply.cards.deck[1].attributes),
                      BaseGame::Chancellor.new(@ply.cards.deck[2].attributes),
                      BasicCards::Duchy.new(@ply.cards.deck[3].attributes),
                      Seaside::Explorer.new(@ply.cards.deck[4].attributes)]
          @ply.cards.deck.each(&:destroy)
          new_deck.each(&:save!)
        end

        should "reveal cards" do
          assert_equal ["Adventurer", "Bazaar", "Chancellor"], @ply.reveal_from_deck(3)
          assert_same_elements(["BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor"], @ply.cards(true).revealed.map(&:type))
          assert_match(/revealed Adventurer, Bazaar, Chancellor\./, @game.histories(true)[-1].event)
        end

        should "handle revealing too many cards" do
          assert_equal(["Adventurer", "Bazaar", "Chancellor",
                        "Duchy", "Explorer"], @ply.reveal_from_deck(7))
          assert_same_elements(["BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor",
                                "BasicCards::Duchy", "Seaside::Explorer"], @ply.cards(true).revealed.map(&:type))
          assert_match(/revealed Adventurer, Bazaar, Chancellor, Duchy, Explorer./, @game.histories(true)[-2].event)
          assert_match(/tried to reveal 2 more cards/, @game.histories[-1].event)
        end

        should "handle shuffling-under" do
          @ply.cards.hand.each {|c| c.location = "discard"; c.save!}
          qshuffle([[3,2,4,0,1], /player\.rb.*under/])
          assert_equal(["Adventurer", "Bazaar", "Chancellor",
                        "Duchy", "Explorer",
                        "Copper", "Estate", "Copper"], @ply.reveal_from_deck(8))
          assert_same_elements(["BasicCards::Estate", "BasicCards::Copper", "BasicCards::Copper",
                                "BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor",
                                "BasicCards::Duchy", "Seaside::Explorer"], @ply.cards(true).revealed.map(&:type))
          assert_match(/revealed Adventurer, Bazaar, Chancellor, Duchy, Explorer, shuffled.*Copper, Estate, Copper/, @game.histories(true)[-1].event)
        end
      end

      context "peeking at cards" do
        setup do
          new_deck = [BaseGame::Adventurer.new(@ply.cards.deck[0].attributes),
                      Seaside::Bazaar.new(@ply.cards.deck[1].attributes),
                      BaseGame::Chancellor.new(@ply.cards.deck[2].attributes),
                      BasicCards::Duchy.new(@ply.cards.deck[3].attributes),
                      Seaside::Explorer.new(@ply.cards.deck[4].attributes)]
          @ply.cards.deck.each(&:destroy)
          new_deck.each(&:save!)
        end

        should "peek at cards" do
          assert_equal ["Adventurer", "Bazaar", "Chancellor"], @ply.peek_at_deck(3)
          assert_same_elements(["BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor"], @ply.cards(true).peeked.map(&:type))
          assert_match(/saw \[#{@ply.id}\?Adventurer, Bazaar, Chancellor\|3 cards\] on the top/, @game.histories(true)[-1].event)
          assert_equal [0,1,2], @ply.peeked_card_ixes
        end

        should "peek at cards at bottom" do
          assert_equal ["Chancellor", "Duchy", "Explorer"], @ply.peek_at_deck(3, :bottom)
          assert_same_elements(["BaseGame::Chancellor", "BasicCards::Duchy", "Seaside::Explorer"], @ply.cards(true).peeked.map(&:type))
          assert_match(/saw \[#{@ply.id}\?Chancellor, Duchy, Explorer\|3 cards\] on the bottom/, @game.histories(true)[-1].event)
        end

        should "handle peeking at too many cards" do
          assert_equal(["Adventurer", "Bazaar", "Chancellor",
                        "Duchy", "Explorer"], @ply.peek_at_deck(7))
          assert_same_elements(["BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor",
                                "BasicCards::Duchy", "Seaside::Explorer"], @ply.cards(true).peeked.map(&:type))
          assert_match(/saw \[#{@ply.id}\?Adventurer, Bazaar, Chancellor, Duchy, Explorer\|5 cards\]/, @game.histories(true)[-2].event)
          assert_match(/tried to look at 2 more cards/, @game.histories[-1].event)
        end

        should "handle shuffling-under" do
          @ply.cards.hand.each {|c| c.location = "discard"; c.save!}
          qshuffle([[3,2,4,0,1], /player\.rb.*under/])
          assert_equal(["Adventurer", "Bazaar", "Chancellor",
                        "Duchy", "Explorer",
                        "Copper", "Estate", "Copper"], @ply.peek_at_deck(8))
          assert_same_elements(["BasicCards::Estate", "BasicCards::Copper", "BasicCards::Copper",
                                "BaseGame::Adventurer", "Seaside::Bazaar", "BaseGame::Chancellor",
                                "BasicCards::Duchy", "Seaside::Explorer"], @ply.cards(true).peeked.map(&:type))
          assert_match(/saw \[#{@ply.id}\?Adventurer, Bazaar, Chancellor, Duchy, Explorer\|5 cards\], shuffled.* \[#{@ply.id}\?Copper, Estate, Copper\|3 cards\]/, @game.histories(true)[-1].event)
        end
      end

      should "identify other players" do
        assert_equal(["Bob", "Chas"], @ply_alan.reload.other_players.map(&:name))
        assert_equal(["Chas", "Alan"], @ply_bob.reload.other_players.map(&:name))
        assert_equal(["Alan", "Bob"], @ply_chas.reload.other_players.map(&:name))
      end

      should "identify next and prev players" do
        assert_equal @ply_bob, @ply_alan.next_player
        assert_equal @ply_chas, @ply_alan.prev_player
      end

      should "calculate score" do
        @ply.calc_score
        assert_equal 3, @ply.reload.score
        @ply.calc_score
        assert_equal 6, @ply.reload.score
      end

      should "format decklist" do
        list = @ply.cards_for_decklist
        assert_match(/Estate \(1 VP\) x3.*Copper x7/, list)
      end
    end
  end
end
