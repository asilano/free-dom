require File.dirname(__FILE__) + '/../test_helper'

class GameTest < ActiveSupport::TestCase
  should      validate_presence_of :name
  should      validate_presence_of :max_players
  should      validate_numericality_of :max_players
  should      ensure_inclusion_of(:max_players).in_range(2..6).with_message(/must be between/)
  
  should "need additional settings to create" do
    assert_raises(ActiveRecord::RecordInvalid) do
      game = Factory.create(:incomplete_game)
    end
  end
  
  should "be able to create a fixed cardset game" do
    assert_nothing_raised do
      game = Factory.create(:fixed_game)
    end
  end
  
  should "be able to create a distributed random game" do
    assert_nothing_raised do
      game = Factory.create(:dist_random_game)
    end
  end
  
  should "be able to create a fully random game" do
    assert_nothing_raised do
      game = Factory.create(:full_random_game)
    end
  end
  
  should "not be able to create a game with fake cards" do
    assert_raises(ActiveRecord::RecordInvalid) do
      game = Factory(:fixed_game, :pile_3 => "Wibble")
    end
  end
  
  should "not be able to create a distributed game with non-10 cards" do
    assert_raises(ActiveRecord::RecordInvalid) do
      game = Factory(:dist_random_game, :num_seaside_cards => 5)
    end
  end
  
  should "not be able to create a full random game with no sets" do
    assert_raises(ActiveRecord::RecordInvalid) do
      game = Factory(:full_random_game, :seaside_present => 0, :intrigue_present => 0)
    end
  end
  
  should have_many(:piles).dependent :destroy
  should have_many(:cards).dependent :delete_all
  should have_many(:players).dependent :destroy
  should have_many(:users).through :players
  should have_many(:histories).dependent :delete_all
  should have_many(:chats).dependent :delete_all
  should have_many(:pending_actions).dependent :delete_all
  
  context "created game" do
    setup do
      @game = Factory(:fixed_game)
    end
    
    should_not  validate_uniqueness_of :name
    
    should "have inited database columns" do
      assert_equal @game.name, "Game 1"
      assert_equal @game.max_players, 3
      assert_equal @game.state, "waiting"
      assert @game.facts.empty?, "Game Facts is not empty"
      assert_nil @game.end_time
    end
    
    should "have initial history" do
      hist = @game.histories[0]
      assert_match(/Game #{@game.name} created./, hist.event)
    end
    
    should "have initial chat" do
      chat = @game.chats[0]
      assert_nil chat.player
      assert_equal "Game", chat.non_ply_name
      assert_equal chat.turn, 0
      assert_match /^Welcome to.*!$/, chat.statement
    end
    
    should "have a pile for each specified card-type" do
      types = @game.piles.map(&:card_type)
      ["BaseGame::Adventurer", "BaseGame::Mine", "BaseGame::Moat", "BaseGame::Thief",
          "Seaside::Treasury", "Seaside::Salvager", "Intrigue::Nobles",
          "Intrigue::Steward", "Prosperity::TradeRoute", "Prosperity::Rabble"].each {|t| assert types.include?(t), types.inspect}
    end
    
    should "have no cards, players, users or pending_actions" do
      assert_blank @game.cards
      assert_blank @game.players
      assert_blank @game.users
      assert_blank @game.pending_actions
    end
    
    should "not be able to start empty game" do
      rc = @game.start_game
      assert_equal "waiting", @game.state
      assert_not_equal "OK", rc
    end
     
    context "with players defined" do
      setup do
        @user_alan = Factory(:user)
        @user_bob = Factory(:user, :name => "Bob", :password => "b")
        @user_chas = Factory(:user, :name => "Chas", :password => "c")
        @user_dave = Factory(:user, :name => "Dave", :password => "d")
        @ply_alan = Factory(:player, :user => @user_alan, :game => nil)
        @ply_bob = Factory(:player, :user => @user_bob, :game => nil)
        @ply_chas = Factory(:player, :user => @user_chas, :game => nil)
        @ply_dave = Factory(:player, :user => @user_dave, :game => nil)
      end
      
      should "be able to add a player to a Game" do
        rc = @game.add_player(@ply_alan)
        assert_equal "OK", rc
        assert_contains(@game.players, @ply_alan)
      end
      
      context "with one player added" do
        setup do
          @game.add_player(@ply_alan)
        end
        
        should "be able to read players' users" do
          assert_contains(@game.users, @user_alan)
        end  
        
        should "not be able to start game" do
          rc = @game.start_game
          assert_not_equal "OK", rc
          assert_equal "waiting", @game.state
        end
        
        should "be able to add players up to game limit" do
          rc = @game.add_player(@ply_bob)
          assert_equal "OK", rc
          assert_contains(@game.players, @ply_bob)
          
          rc = @game.add_player(@ply_chas)
          assert_equal "OK", rc
          assert_contains(@game.players, @ply_chas)
        end
        
        should "not be able to add players beyond game limit" do
          @game.add_player(@ply_bob)
          @game.add_player(@ply_chas)
          
          ex = assert_raise(RuntimeError) do
            @game.add_player(@ply_dave)
          end
          assert_match(/full/, ex.message)
          assert_does_not_contain(@game.players, @ply_dave)
        end
        
        context "with three players added" do
          setup do
            @game.add_player(@ply_bob)
            @game.add_player(@ply_chas)
          end
          
          should "be able to start game" do
            rc = @game.start_game
            assert_equal "OK", rc
            assert_equal "running", @game.state
          end
          
          context "with game running" do
            setup do
              qshuffle([[0,1,2], /start_game/, /player\.rb/])
              @game.start_game
            end
            
            should "have cards defined" do
              total_cards = 0              
              total_cards += 36  # There should be 3 Victory piles of 12 each...
              total_cards += 30  # ... 3 Treasure piles of 10 each (initially)...
              total_cards += 20  # ... a Curse pile of 20...
              total_cards += 102 # ... 10 Kingdom piles of 10 each, except Nobles which is 12...
              total_cards += 30  # ... and three players' decks of 10 each.
              assert_equal total_cards, @game.cards(true).length
            end
            
            should "give players starting decks" do
              deck = ["BasicCards::Estate"] * 3 + ["BasicCards::Copper"] * 7
              assert_same_elements deck, @ply_alan.cards.map(&:type)
              assert_same_elements deck, @ply_bob.cards.map(&:type)
              assert_same_elements deck, @ply_chas.cards.map(&:type)
            end
            
            should "have pending actions initialised" do            
              pid = @ply_alan.id
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
EOF
              assert_pend_acts_like(patt, @game.pending_actions)
            end
            
            should "detect game end by Province" do
              @game.cards.of_type("BasicCards::Province").each {|p| p.location = "limbo"; p.pile = nil; p.save!}
              @game.process_actions
              
              assert_equal "end_game", @game.root_action(true).expected_action
              hist = @game.histories[-1]
              assert_match(/Game will end/, hist.event)
            end
            
            should "detect game end by non-Province" do
              @game.cards.of_type("BasicCards::Duchy").each {|p| p.location = "limbo"; p.pile = nil; p.save!}
              @game.cards.of_type("BaseGame::Mine").each {|p| p.location = "limbo"; p.pile = nil; p.save!}
              @game.cards.of_type("Seaside::Salvager").each {|p| p.location = "limbo"; p.pile = nil; p.save!}
              @game.process_actions
              
              assert_equal "end_game", @game.root_action(true).expected_action
              hist = @game.histories[-1]
              assert_match(/Game will end/, hist.event)
            end
            
            should "process game end" do
              @game.cards.of_type("BasicCards::Province").each {|p| p.location = "limbo"; p.pile = nil; p.save!}
              @game.process_actions
              
              @game.pending_actions[0..3].each {|pa| pa.destroy}
              @game.process_actions
              
              assert_equal "ended", @game.state
              
              hist = @game.histories[-1]
              assert_match(/Game ended/, hist.event)
            end
          end
        end
      end
    end  
  end
end
