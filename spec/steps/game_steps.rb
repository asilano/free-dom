module GameSteps
  def self.included(base)
    [SetupSteps, ActionSteps, CheckSteps].each { |mod| base.include mod }
  end

  step "pending :reason" do |reason|
    skip reason
  end
  step "pending" do
    skip
  end

  module SetupSteps
    step 'I am in a :count player game' do |count|
      @game = FactoryBot.create(:game_with_kingdom)
      @player_count = count
      @player_names = PLAYER_NAMES[0, count]
      @user_alan = @game.users.first
      @user_alan.update!(name: "Alan")
      FactoryBot.create(:add_player_journal, game: @game, user: @user_alan)

      (count - 1).times do |n|
        name = PLAYER_NAMES[n + 1]
        user = FactoryBot.create(:user, name: name)
        FactoryBot.create(:add_player_journal, game: @game, user: user)
      end

      FactoryBot.create(:start_game_journal, game: @game, user: @user_alan)
    end

    step 'the kingdom choice contains :cards' do |cards|
      kingdom_journal = @game.journals.where(type: 'GameEngine::ChooseKingdomJournal').first
      list = cards.map(&:to_s) + kingdom_journal.params['card_list']
      kingdom_journal.params['card_list'] = list.uniq.take 10
      kingdom_journal.save
      @game.reload
    end

    step 'the kingdom choice contains the :project project' do |project|
      kingdom_journal = @game.journals.where(type: 'GameEngine::ChooseKingdomJournal').first
      kingdom_journal.params['card_list'] << project.to_s
      kingdom_journal.save
      @game.reload
    end

    step ':player_name :location contains :cards' do |name, location, cards|
      player = get_player(name)
      make_journal(user: player.user,
                   type: GameEngine::HackJournal,
                   params: { scope: location,
                             action: :set,
                             cards: cards.map(&:to_s) })
    end

    step 'the :card pile is empty' do |card|
      make_journal(user:   nil,
                   type:   GameEngine::HackJournal,
                   params: { scope:      :supply,
                             action:     :set,
                             card_class: card.to_s,
                             cards:      []
                           })
    end

    step 'the supply is empty' do
      @game.game_state.piles.each do |pile|
        make_journal(user:   nil,
                     type:   GameEngine::HackJournal,
                     params: { scope:      :supply,
                               action:     :set,
                               card_class: pile.card_class.to_s,
                               cards:      []
                             })
      end
    end

    step 'the :card pile contains :cards' do |card, cards|
      make_journal(user:   nil,
                   type:   GameEngine::HackJournal,
                   params: { scope:      :supply,
                             action:     :set,
                             card_class: card.to_s,
                             cards:      cards.map(&:to_s)
                           })
    end

    step 'the trash contains :cards' do |cards|
      make_journal(user:   nil,
                   type:   GameEngine::HackJournal,
                   params: { scope:  :trash,
                             action: :set,
                             cards:  cards.map(&:to_s)
                           })
    end

    step ':player_name has/have the :artifact' do |name, artifact|
      player = get_player(name)
      make_journal(user:   player.user,
                   type:   GameEngine::HackJournal,
                   params: { scope: :artifact_owner,
                             key:   :"#{artifact}"
                           })
    end

    step ':player_name has/have the :project project' do |name, project|
      player = get_player(name)
      make_journal(user:   player.user,
                   type:   GameEngine::HackJournal,
                   params: { scope:   :project_owner,
                             project: :"#{project}"
                           })
    end

    step ':player_name has/have :count Villager(s)' do |name, count|
      player = get_player(name)
      make_journal(user:   player.user,
                   type:   GameEngine::HackJournal,
                   params: { scope: :villagers,
                             count: count })
    end

    step ':player_name has/have :count Coffer(s)' do |name, count|
      player = get_player(name)
      make_journal(user:   player.user,
                   type:   GameEngine::HackJournal,
                   params: { scope: :coffers,
                             count: count })
    end

    step "there is/are :count of :player_name tokens on the :project project" do |count, name, project|
      player = get_player(name)
      make_journal(user:   player.user,
                   type:   GameEngine::HackJournal,
                   params: {
                     scope:   :project_tokens,
                     project: :"#{project}",
                     count:   count
                   })
    end
  end

  module ActionSteps
    step ':player_name choose(s) :cards in/on my/his/her/the :scope( cards)' do |name, cards, scope|
      user = get_player(name).user
      question = @questions.detect { |q| q&.player&.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      scope = scope.to_sym
      unless controls.map(&:scope).any? { |s| s == :everywhere }
        if scope == :supply
          expect(controls).to include(have_attributes(scope: satisfy { %i[supply full_supply].include? _1 }))
        else
          expect(controls).to include(have_attributes(scope: scope))
        end
      end
      scopes = [scope, :everywhere]
      scopes << :full_supply if scope == :supply
      control = controls.detect { |c| scopes.include?(c.scope) }
      make_journal(user: user,
                   type: question.journal_type,
                   fiber_id: question.fiber_id,
                   params: control.handle_choice(cards))

      # If the question is for a PlayActionJournal, record the chosen card
      # as the last action played
      @last_action_played = cards[0] if question.journal_type == GameEngine::PlayActionJournal
    end

    step ":player_name choose(s) :cards in play" do |name, cards|
      send ":player_name choose(s) :cards in/on my/his/her/the :scope( cards)", name, cards, "play"
    end

    step ':player_name choose(s) :multi_options in/on my/his/her/the :scope( cards)' do |name, choices, scope|
      user = get_player(name).user
      question = @questions.detect { |q| q&.player&.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      scope = scope.to_sym
      unless controls.map(&:scope).any? { |s| s == :everywhere }
        expect(controls).to include(have_attributes(scope: scope))
      end
      control = controls.detect { |c| c.scope == scope || c.scope == :everywhere }
      make_journal(user:     user,
                   type:     question.journal_type,
                   fiber_id: question.fiber_id,
                   params:   control.handle_choice(choices))
    end

    step ':player_name choose(s) the option :option' do |name, option|
      user = get_player(name).user
      question = @questions.detect { |q| q&.player&.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      expect(controls).to include(have_attributes(scope: :player))

      control = controls.detect { |c| c.scope == :player }
      make_journal(user:     user,
                   type:     question.journal_type,
                   fiber_id: question.fiber_id,
                   params:   control.handle_choice(option))
    end

    step ":player_name choose(s) the :project project" do |name, project|
      user = get_player(name).user
      question = @questions.detect { |q| q&.player&.name == user.name }
      controls = question.controls_for(user, @game.game_state)

      scope = :full_supply
      unless controls.map(&:scope).any? { |s| s == :everywhere }
        expect(controls).to include(have_attributes(scope: scope))
      end
      control = controls.detect { |c| c.scope == scope || c.scope == :everywhere }
      make_journal(user: user,
                   type: question.journal_type,
                   fiber_id: question.fiber_id,
                   params: control.handle_choice(project))
    end

    step ':player_name spend(s) :amount Coffer(s)' do |name, amount|
      user = get_player(name).user
      question = @questions.detect do |q|
        q&.player&.name == user.name && q&.journal_type == GameEngine::SpendCoffersJournal
      end
      controls = question.controls_for(user, @game.game_state)
      expect(controls).to include(have_attributes(scope: :with_hand))

      control = controls.detect { |c| c.scope == :with_hand }
      make_journal(user:     user,
                   type:     'GameEngine::SpendCoffersJournal',
                   fiber_id: question.fiber_id,
                   params:   control.handle_choice(amount))
    end

    step ':player_name spend(s) :amount Villager(s)' do |name, amount|
      user = get_player(name).user
      question = @questions.detect do |q|
        q&.player&.name == user.name && q&.journal_type == GameEngine::SpendVillagersJournal
      end
      controls = question.controls_for(user, @game.game_state)
      expect(controls).to include(have_attributes(scope: :with_hand))

      control = controls.detect { |c| c.scope == :with_hand }
      make_journal(user:     user,
                   type:     'GameEngine::SpendVillagersJournal',
                   fiber_id: question.fiber_id,
                   params:   control.handle_choice(amount))
    end

    step ":player_name pass(es) through to :player_name next turn" do |name, next_name|
      pass_through_turn(name, next_name, false)
    end

    step ":player_name pass(es) through to just before :player_name next turn" do |name, next_name|
      pass_through_turn(name, next_name, true)
    end

    def pass_through_turn(name, next_name, just_before)
      name.replace('Alan') if name == "I"
      next_name.replace("Alan") if next_name == "I"

      first = true
      prev_name = @player_names[@player_names.index(next_name) - 1]
      @player_names.rotate(@player_names.index(name)).each do |inner_name|
        break if inner_name == next_name && !first
        first = false
        @game.process
        @questions = @game.questions
        if @game.game_state.phase == :action
          step "#{inner_name} chooses 'Leave Action Phase' in his hand"
        end
        step "#{inner_name} should need to 'Play Treasures, or pass'"
        step "#{inner_name} choose 'Stop playing treasures' in his hand"
        step "#{inner_name} should need to 'Buy a card, or pass'"
        step "#{inner_name} choose 'Buy nothing' in the supply"
        step "cards should move as follows:"
        step   "#{inner_name} should discard everything from his hand"
        step   "#{inner_name} should discard everything from play"
        step   "#{inner_name} should draw 5 cards"
        break if inner_name == prev_name && just_before
        step "these card moves should happen"
      end
    end
  end

  module CheckSteps
    step ':player_name :whether_to need to :question' do |name, should, question|
      @game.process
      @questions = @game.questions
      player = get_player(name)

      if should
        expect(@questions.compact.map(&:player)).to include(be == player)
        unless question == 'act'
          expect(@questions.compact.select { |q| q.player == player }.map { |q| q.text(@game.game_state) }).to include(be == question)
        end
      else
        if question == 'act'
          expect(@questions.compact.map(&:player)).not_to include(be == player)
        else
          expect(@questions.compact.select { |q| q.player == player }.map { |q| q.text(@game.game_state) }).to_not include(be == question)
        end
      end
    end

    step ':player_name hand should contain :cards' do |name, cards|
      @game.process
      player = get_player(name)
      expect(player.hand_cards.map { |c| c.class.to_s }).to match_array(cards.map(&:to_s))
    end

    step ':player_name deck should contain :cards' do |name, cards|
      @game.process
      player = get_player(name)
      expect(player.deck_cards.map { |c| c.class.to_s }).to match_array(cards.map(&:to_s))
    end

    step ':player_name should have :cards in play' do |name, cards|
      @game.process
      player = get_player(name)
      expect(player.played_cards.map { |c| c.class.to_s }).to match_array(cards.map(&:to_s))
    end

    step ':cards should be revealed on :player_name deck' do |cards, name|
      @game.process
      player = get_player(name)
      expect(player.revealed_cards.select { |c| c.location == :deck }.map { |c| c.class.to_s }).to match_array(cards.map(&:to_s))
    end

    step ":cards in/on :player_name :scope :whether_to be visible to :player_name" do |cards, owner_name, scope, visible, viewer_name|
      @game.process
      owner = get_player(owner_name)
      viewer = get_player(viewer_name)
      scope = scope.downcase.to_sym
      scope_cards = owner.cards.select { |c| c.location == scope }
      scope_cards.each do |c|
        next unless cards.include?(c.class)
        expect(c.visible_to?(viewer)).to eq visible
      end
    end

    step 'cards should move as follows:' do
      # Process all but the last-added journal
      @game.journals.last.ignore = true
      @game.process

      # Take a record of the cards in the game at this time.
      @cards_before = extract_game_cards

      # If the last-added journal was a PlayActionJournal, expect the last played action to move
      if @game.journals.last.is_a? GameEngine::PlayActionJournal
        action = cards_for_player(@game.journals.last.player.name, location: 'hand').detect { |c| c[:class] == @last_action_played }
        action[:location] = :play if action
      end

      # Unignore the last-added journal
      @game.journals.last.ignore = false
    end

    step 'these card moves should happen' do
      @game.process
      cards_now = extract_game_cards
      cards_now[:players].each.with_index do |cards, ix|
        grouped_cards = cards.group_by { |c| c[:location] }
        group_before = @cards_before[:players][ix].group_by { |c| c[:location] }
        grouped_cards.each do |location, group_now|
          begin
            if location == :deck
              expect(group_now).to eql(group_before[location])
            else
              expect(group_now).to match_array(group_before[location])
            end
          rescue RSpec::Expectations::ExpectationNotMetError
            $!.message << "\n - in location #{location} for #{PLAYER_NAMES[ix]}. Expected #{group_before[location]&.length || 0}, got #{group_now.length}"
            raise
          end
        end
      end
      cards_now[:supply].each.with_index do |cards, ix|
        expect(cards).to match_array @cards_before[:supply][ix]
      end
    end

    step 'cards should not move' do
      send 'cards should move as follows:'
      send 'these card moves should happen'
    end

    step ':player_name should discard :cards from/in( my/his/her) (in ):location( cards)' do |name, cards, location|
      players_cards = cards_for_player(name, location: location)
      if cards == 'everything'
        players_cards.each { |c| c[:location] = :discard; c[:revealed] = false }
      else
        cards.each do |type|
          card = players_cards.delete_at(players_cards.index { |c| c[:class] == type })
          card[:location] = :discard
          card[:revealed] = false
        end
      end
    end

    step ':player_name should draw :count card(s)' do |name, count|
      players_cards = cards_for_player(name, location: :deck)
      if players_cards.count < count
        # Not enough to draw. "Shuffle" the discards
        shuffle_discard_under_deck(cards_for_player(name))
        players_cards = cards_for_player(name, location: :deck)
      end

      players_cards.take(count).each { |c| c[:location] = :hand }
    end

    step ':player_name should reveal :count card(s) from my/his/her deck' do |name, count|
      players_cards = cards_for_player(name, location: :deck)
      if players_cards.count < count
        # Not enough to draw. "Shuffle" the discards
        shuffle_discard_under_deck(cards_for_player(name))
        players_cards = cards_for_player(name, location: :deck)
      end

      players_cards.take(count).each { |c| c[:revealed] = true }
    end

    step ':player_name should unreveal :cards from my/his/her deck' do |name, cards|
      players_cards = cards_for_player(name)
      cards.each do |card|
        instance_ix = players_cards.index { |c| c[:class] == card && c[:location] == :deck }
        instance = players_cards[instance_ix]
        instance[:revealed] = false
      end
    end

    step ":player_name should shuffle my/his/her discards" do |name|
      shuffle_discard_under_deck(cards_for_player(name))
    end

    step ':player_name should gain :cards' do |name, cards|
      send ':player_name should gain :cards from :source to my/his/her :destination', name, cards, 'supply', 'discard'
    end

    step ':player_name should gain :cards to my/his/her :destination' do |name, cards, destination|
      send ':player_name should gain :cards from :source to my/his/her :destination', name, cards, 'supply', destination
    end

    step ':player_name should gain :cards from :source to my/his/her :destination' do |name, cards, source, destination|
      players_cards = cards_for_player(name)
      cards.each do |card|
        if source == 'supply'
          pile = @cards_before[:supply].detect { |p_cards| p_cards.last == card || p_cards.first[:class] == card }
          pile.delete_at(0)
        end
        players_cards.unshift({ class: card, location: destination.to_sym, location_card: {}, revealed: false })
      end
    end

    step ":player_name should return :cards to the supply from my/his/her :source" do |name, cards, source|
      players_cards = cards_for_player(name)
      cards.each do |card|
        instance_ix = players_cards.index { |c| c[:class] == card && c[:location] == source.to_sym }
        instance = players_cards[instance_ix]
        players_cards.delete_at(instance_ix)

        pile = @cards_before[:supply].detect { |p_cards| p_cards.last == card || p_cards.first[:class] == card }
        instance[:location] = :pile
        instance[:revealed] = false
        instance[:location_card] = {}
        pile.unshift(instance)
      end
    end

    step ":player_name should return :cards to the supply from in play" do |name, cards|
      send ":player_name should return :cards to the supply from my/his/her :source", name, cards, "play"
    end

    step ':player_name should move :cards from my/his/her :source to my/his/her :destination' do |name, cards, source, destination|
      players_cards = cards_for_player(name)
      cards.reverse_each do |card|
        instance_ix = players_cards.index { |c| c[:class] == card && c[:location] == source.to_sym }
        instance = players_cards[instance_ix]
        instance[:location] = destination.to_sym
        instance[:revealed] = false
        instance[:location_card] = {}
        if destination == "deck"
          players_cards.delete_at(instance_ix)
          players_cards.unshift(instance)
        end
      end
    end

    step ':player_name should move :cards from in play to my/his/her :destination' do |name, cards, destination|
      send ':player_name should move :cards from my/his/her :source to my/his/her :destination', name, cards, 'play', destination
    end

    step ':player_name should move :cards from my/his/her :source to in play' do |name, cards, source|
      send ':player_name should move :cards from my/his/her :source to my/his/her :destination', name, cards, source, 'play'
    end

    step ':player_name should move :cards from being set aside to my/his/her :destination' do |name, cards, destination|
      send ':player_name should move :cards from my/his/her :source to my/his/her :destination', name, cards, "set_aside", destination
    end

    step ':player_name should trash :cards from my/his/her :source( cards)' do |name, cards, source|
      players_cards = cards_for_player(name)
      cards.each do |card|
        instance_ix = players_cards.index { |c| c[:class] == card && c[:location] == source.to_sym }
        instance = players_cards.delete_at(instance_ix)
        instance[:location] = :trash
        instance[:revealed] = false
      end
    end

    step ':player_name should trash :cards from in play' do |name, cards|
      send ':player_name should trash :cards from my/his/her :source( cards)', name, cards, 'play'
    end

    step ":player_name should set aside :cards from my :location on my/his/her :card :location" do |name, cards, source, host, destination|
      players_cards = cards_for_player(name)
      if destination == "trash"
        host_card = extract_game_cards[:trash].detect { |c| c[:class] == host }
      else
        host_card = players_cards.detect { |c| c[:class] == host && c[:location] == destination.to_sym }
      end
      cards.each do |card|
        instance_ix = players_cards.index { |c| c[:class] == card && c[:location] == source.to_sym }
        instance = players_cards[instance_ix]
        instance[:location] = :set_aside
        instance[:location_card] = host_card
        instance[:revealed] = false
      end
    end

    step ":player_name should set aside :cards from my :location on my/his/her :card in play" do |name, cards, source, host|
      send ":player_name should set aside :cards from my :location on my/his/her :card :location", name, cards, source, host, "play"
    end

    step ":player_name should set aside :cards from my :location on the :card in the trash" do |name, cards, source, host|
      send ":player_name should set aside :cards from my :location on my/his/her :card :location", name, cards, source, host, "trash"
    end

    step ":player_name should set aside :cards from my :location" do |name, cards, source|
      players_cards = cards_for_player(name)
      cards.each do |card|
        instance_ix = players_cards.index { |c| c[:class] == card && c[:location] == source.to_sym }
        instance = players_cards[instance_ix]
        instance[:location] = :set_aside
        instance[:revealed] = false
      end
    end

    step ':player_name :whether_to be able to choose the :cards pile(s)' do |name, should, cards|
      user = get_player(name).user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| %i[supply full_supply].include? c.scope }
      can_pick = cards.map do |card|
        pile = @game.game_state.piles.detect { |p| p.cards.first.is_a? card }
        pile && control.filter(pile.cards.first)
      end

      expect(can_pick).to all(should ? be_truthy : be_falsey)
    end

    step ':player_name :whether_to be able to choose the :project project' do |name, should, project|
      user = get_player(name).user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| c.scope == :full_supply }
      project_instance = @game.game_state.card_shapeds.detect { |c| c.is_a? project }
      can_pick = project_instance && control.filter(project_instance)

      if should
        expect(can_pick).to be_truthy
      else
        expect(can_pick).to be_falsey
      end
    end

    step ':player_name :whether_to be able to choose nothing in the supply' do |name, should|
      user = get_player(name).user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| c.scope == :supply }

      if should
        expect(control.cardless_buttons).to_not be_empty
      else
        expect(control.cardless_buttons).to be_empty
      end
    end

    step ':player_name :whether_to be able to choose :cards in his/her/my hand' do |name, should, cards|
      player = get_player(name)
      user = player.user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| c.scope == :hand }

      if cards.empty?
        # :cards was "nothing"
        if should
          expect(control.cardless_buttons).to_not be_empty
        else
          expect(control.cardless_buttons).to be_empty
        end
      else
        can_pick = cards.map do |card|
          hand_card = player.hand_cards.detect { |c| c.is_a? card }
          hand_card && control.filter(hand_card)
        end

        expect(can_pick).to all(should ? be_truthy : be_falsey)
      end
    end

    step ':player_name :whether_to be able to choose :cards in play' do |name, should, cards|
      player = get_player(name)
      user = player.user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| c.scope == :play }

      if cards.empty?
        # :cards was "nothing"
        if should
          expect(control.cardless_buttons).to_not be_empty
        else
          expect(control.cardless_buttons).to be_empty
        end
      else
        can_pick = cards.map do |card|
          played_card = player.played_cards.detect { |c| c.is_a? card }
          played_card && control.filter(played_card)
        end

        expect(can_pick).to all(should ? be_truthy : be_falsey)
      end
    end

    step ':player_name :whether_to be able to choose :cards in the trash' do |name, should, cards|
      player = get_player(name)
      user = player.user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| c.scope == :trash }

      if cards.empty?
        # :cards was "nothing"
        if should
          expect(control.cardless_buttons).to_not be_empty
        else
          expect(control.cardless_buttons).to be_empty
        end
      else
        can_pick = cards.map do |card|
          trashed_card = @game.game_state.trashed_cards.detect { |c| c.is_a? card }
          trashed_card && control.filter(trashed_card)
        end

        expect(can_pick).to all(should ? be_truthy : be_falsey)
      end
    end

    step ':player_name :whether_to be able to choose :cards in my/his/her discard' do |name, should, cards|
      player = get_player(name)
      user = player.user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| c.scope == :discard }

      if cards.empty?
        # :cards was "nothing"
        if should
          expect(control.cardless_buttons).to_not be_empty
        else
          expect(control.cardless_buttons).to be_empty
        end
      else
        can_pick = cards.map do |card|
          discarded_card = player.discarded_cards.detect { |c| c.is_a? card }
          discarded_card && control.filter(discarded_card)
        end

        expect(can_pick).to all(should ? be_truthy : be_falsey)
      end
    end

    step ':player_name :whether_to be able to choose the option :option' do |name, should, option|
      user = get_player(name).user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| c.scope == :player }

      if should
        expect(control.values.map(&:first)).to include(option)
      else
        expect(control.values.map(&:first)).to_not include(option)
      end
    end

    step "the :card pile should cost :amount" do |card, amount|
      pile = @game.game_state.piles.detect { |p| p.cards.first.is_a? card }
      expect(pile.cards.first.cost).to eq(amount)
    end

    step ':player_name should have :count action(s)' do |name, count|
      @game.process
      expect(get_player(name).actions).to eq count.to_i
    end

    step ':player_name should have :count buy(s)' do |name, count|
      @game.process
      expect(get_player(name).buys).to eq count.to_i
    end

    step ':player_name should have $:amount' do |name, amount|
      @game.process
      expect(get_player(name).cash).to eq amount.to_i
    end

    step ':player_name should have :amount Coffer(s)' do |name, amount|
      @game.process
      expect(get_player(name).coffers).to eq amount.to_i
    end

    step ':player_name should have :amount Villager(s)' do |name, amount|
      @game.process
      expect(get_player(name).villagers).to eq amount.to_i
    end

    step ':player_name total score should be :score' do |name, score|
      @game.process
      expect(get_player(name).calculate_score).to eq score.to_i
    end

    step ':player_name :whether_to have the :artifact' do |name, should, artifact|
      @game.process
      if should
        expect(@game.game_state.artifacts[artifact].owner).to eq get_player(name)
      else
        expect(@game.game_state.artifacts[artifact].owner).not_to eq get_player(name)
      end
    end

    step "there should be :count of :player_name tokens on the :project project" do |count, name, project|
      @game.process
      project_card = @game.game_state.card_shapeds.detect { |cs| cs.is_a? project }
      expect(project_card.player_tokens[get_player(name)]).to eq count
    end

    step "the last journal :whether_to be fixed" do |should|
      @game.process
      journal = @game.journals.last
      if should
        expect(@game.fiber_last_fixed_journal_orders[journal.fiber_id]).to eq(journal.order), "#{journal.class} should be fixed"
      else
        expect(@game.fiber_last_fixed_journal_orders[journal.fiber_id]).not_to eq(journal.order), "#{journal.class} should not be fixed"
      end
    end

    step "the game should have ended" do
      @game.process
      expect(@game.run_state).to eq :ended
    end
  end

  def get_player(name)
    name.replace('Alan') if name == 'I'
    @game.process unless @game.game_state
    puts name unless PLAYER_NAMES.index(name)
    @game.game_state.players[PLAYER_NAMES.index(name)]
  end

  def extract_game_cards
    player_cards = @game.game_state.players.map do |ply|
      ply.cards.map { |c| extract_card(c) }
    end
    supply_cards = @game.game_state.piles.map do |p|
      p.cards.map { |c| extract_card(c) } + [p.card_class]
    end
    trash_cards = @game.game_state.trashed_cards.map { extract_card(_1) }
    { players: player_cards, supply: supply_cards, trash: trash_cards }
  end

  def extract_card(card)
    return {} if card.nil?

    {
      class:         card.class,
      location:      card.location,
      revealed:      !!card.revealed,
      location_card: extract_card(card.location_card)
    }
  end

  def cards_for_player(name, location: nil)
    name.replace('Alan') if name == 'I'
    cards = @cards_before[:players][PLAYER_NAMES.index(name)]
    cards = cards.select { |c| c[:location] == location.to_sym } if location
    cards
  end

  def shuffle_discard_under_deck(cards)
    discards, other = cards.partition { |c| c[:location] == :discard }
    cards.replace(other + discards.sort_by { |c| c[:class].readable_name }
                                  .each    { |c| c[:location] = :deck })
  end

  def make_journal(**kwargs)
    @game.journals.create(order: @game.journals.map(&:order).max + 1, **kwargs)
  end
end

# Monkey-patch in methods for each control type to handle being told what to do
# Each returns the params for the journal that will be created.
Control.define_method(:handle_choice) do |_|
  @params || {}
end

OneCardControl.define_method(:handle_choice) do |choice|
  # First, check for the null choice
  if button = cardless_buttons.detect { _1[:text] == choice }
    return { @key => button[:value] }
  end

  # Otherwise, find the index requested
  choice = choice.first if choice.is_a? Array
  { @key => find_index(self, @player, @game_state, @scope, @filter, choice) }.merge(super(choice))
end
MultiCardControl.define_method(:handle_choice) do |choice|
  # First, check for choosing nothing
  return { @key => [] }.merge(super(choice)) if choice == []

  # Now check for it being a null choice
  if button = cardless_buttons.detect { _1[:text] == choice }
    return { @key => button[:value] }.merge(super(choice))
  end

  if choice == 'everything'
    set = @player.cards_by_location(@scope).map.with_index.select { |c, ix| filter(c) }.map(&:second)
    return { @key => set }.merge(super(choice))
  end

  # Otherwise, find the indices requested
  case @scope
  when :hand
    hand_cards = @player.hand_cards.dup
    indices = choice.map do |type|
      ix = hand_cards.index { |c| c.is_a? type }
      hand_cards[ix] = nil
      ix
    end
    { @key => indices }.merge(super(choice))
  end
end
MultiCardChoicesControl.define_method(:handle_choice) do |choices|
  # First, check for choosing nothing
  return { @key => [] }.merge(super(choices)) if choices == []

  params = {}

  choices.each do |pair|
    params[find_index(self, @player, @game_state, @scope, @filter, pair[0])] = @choices.detect { |opt| opt[0] == pair[1] }[1]
  end
  { @key => params }.merge(super(choices))
end

ButtonControl.define_method(:handle_choice) do |choice|
  { @key => @values.detect { |opt| opt[0] == choice }[1] }.merge(super(choice))
end

NumberControl.define_method(:handle_choice) do |choice|
  { @key => choice.to_s }.merge(super(choice))
end

def find_index(control, player, game_state, scope, filter, card)
  case scope
  when :hand
    player.hand_cards.index { |c| c.is_a?(card) && control.instance_exec(c, &filter) }
  when :deck
    player.deck_cards.index { |c| c.is_a?(card) && control.instance_exec(c, &filter) }
  when :discard
    player.discarded_cards.index { |c| c.is_a?(card) && control.instance_exec(c, &filter) }
  when :play
    player.played_cards.index { |c| c.is_a?(card) && control.instance_exec(c, &filter) }
  when :revealed
    player.cards_revealed_to(@question).index { |c| c.is_a?(card) && control.instance_exec(c, &filter) }
  when :peeked
    player.cards_peeked_to(@question).index { |c| c.is_a?(card) && control.instance_exec(c, &filter) }
  when :supply, :full_supply
    ix = game_state.piles.index { |pile| pile.cards.first.is_a?(card) && control.instance_exec(pile.cards.first, &filter) }
    if ix.nil?
      ix = game_state.card_shapeds.index { |cs| cs.is_a?(card) && control.instance_exec(cs, &filter) }
      ix += game_state.piles.length
    end
    ix
  when :trash
    game_state.trashed_cards.index { |c| c.is_a?(card) && control.instance_exec(c, &filter) }
  when :everywhere
    player.cards.index { |c| c.is_a?(card) && control.instance_exec(c, &filter) }
  end
end
