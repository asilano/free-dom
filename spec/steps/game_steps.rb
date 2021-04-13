module GameSteps
  PLAYER_NAMES = %w[Alan Belle Chas Donna Eddie Fiona].freeze

  def self.included(base)
    [SetupSteps, ActionSteps, CheckSteps].each { |mod| base.include mod }
  end

  module SetupSteps
    step 'I am in a :count player game' do |count|
      @game = FactoryBot.create(:game_with_kingdom)
      @user_alan = @game.users.first
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
  end

  module ActionSteps
    step ':player_name choose(s) :cards in/on my/his/her/the :scope( cards)' do |name, cards, scope|
      user = get_player(name).user
      question = @questions.detect { |q| q&.player&.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      scope = scope.to_sym
      unless controls.map(&:scope).any? { |s| s == :everywhere }
        expect(controls).to include(have_attributes(scope: scope))
      end
      control = controls.detect { |c| c.scope == scope || c.scope == :everywhere }
      make_journal(user: user,
                   type: question.journal_type,
                   fiber_id: question.fiber_id,
                   params: control.handle_choice(cards))

      # If the question is for a PlayActionJournal, record the chosen card
      # as the last action played
      @last_action_played = cards[0] if question.journal_type == GameEngine::PlayActionJournal
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
  end

  module CheckSteps
    step ':player_name should need to :question' do |name, question|
      @game.process
      @questions = @game.questions
      player = get_player(name)

      expect(@questions.compact.map(&:player)).to include(be == player)
      expect(@questions.compact.select { |q| q.player == player }.map { |q| q.text(@game.game_state) }).to include(be == question)
    end

    step ':player_name should not need to act' do |name|
      @game.process
      @questions = @game.questions
      player = get_player(name)

      expect(@questions.compact.map(&:player)).not_to include(be == player)
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

    step 'cards should move as follows:' do
      # Process all but the last-added journal
      @game.journals.last.ignore = true
      @game.process

      # Take a record of the cards in the game at this time.
      @cards_before = extract_game_cards

      # If the last-added journal was a PlayActionJournal, expect the last played action to move
      if @game.journals.last.is_a? GameEngine::PlayActionJournal
        action = cards_for_player(@game.journals.last.player.name, location: 'hand').detect { |c| c[:class] == @last_action_played }
        action[:location] = :play
      end

      # Unignore the last-added journal
      @game.journals.last.ignore = false
    end

    step 'these card moves should happen' do
      @game.process
      cards_now = extract_game_cards
      #byebug if @cards_before.values.flatten.any? { |c| !c.key? :revealed }
      cards_now[:players].each.with_index do |cards, ix|
        grouped_cards = cards.group_by { |c| c[:location] }
        group_before = @cards_before[:players][ix].group_by { |c| c[:location] }
        grouped_cards.each do |location, group_now|
          begin
            expect(group_now).to match_array(group_before[location])
          rescue RSpec::Expectations::ExpectationNotMetError
            $!.message << "\n - in location #{location}"
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

    step ':player_name should discard :cards from/in( my/his/her) :location( cards)' do |name, cards, location|
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
          pile = @cards_before[:supply].detect { |p_cards| p_cards.first[:class] == card }
          pile.delete_at(0)
        end
        players_cards << { class: card, location: destination.to_sym, revealed: false }
      end
    end

    step ':player_name should move :cards from my/his/her :source to my/his/her :destination' do |name, cards, source, destination|
      players_cards = cards_for_player(name)
      cards.each do |card|
        instance_ix = players_cards.index { |c| c[:class] == card && c[:location] == source.to_sym }
        instance = players_cards[instance_ix]
        instance[:location] = destination.to_sym
        instance[:revealed] = false
        if destination == 'deck'
          players_cards.delete_at(instance_ix)
          players_cards.unshift(instance)
        end
      end
    end

    step ':player_name should move :cards from my/his/her :source to in play' do |name, cards, source|
      send ':player_name should move :cards from my/his/her :source to my/his/her :destination', name, cards, source, 'play'
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

    step ':player_name :whether_to be able to choose the :cards pile(s)' do |name, should, cards|
      user = get_player(name).user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| c.scope == :supply }
      can_pick = cards.map do |card|
        pile = @game.game_state.piles.detect { |p| p.cards.first.is_a? card }
        pile && control.filter(pile.cards.first)
      end

      expect(can_pick).to all(should ? be_truthy : be_falsey)
    end

    step ':player_name :whether_to be able to choose nothing in the supply' do |name, should|
      user = get_player(name).user
      question = @questions.detect { |q| q.player.name == user.name }
      controls = question.controls_for(user, @game.game_state)
      control = controls.detect { |c| c.scope == :supply }

      if should
        expect(control.cardless_button).to_not be_nil
      else
        expect(control.cardless_button).to be_nil
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
          expect(control.cardless_button).to_not be_nil
        else
          expect(control.cardless_button).to be_nil
        end
      else
        can_pick = cards.map do |card|
          hand_card = player.hand_cards.detect { |c| c.is_a? card }
          hand_card && control.filter(hand_card)
        end

        expect(can_pick).to all(should ? be_truthy : be_falsey)
      end
    end

    step ':player_name should have :count action(s)' do |name, count|
      @game.process
      expect(get_player(name).actions).to eq count.to_i
    end

    step ':player_name should have :count buy(s)' do |name, count|
      @game.process
      expect(get_player(name).buys).to eq count.to_i
    end

    step ':player_name should have :amount cash' do |name, amount|
      @game.process
      expect(get_player(name).cash).to eq amount.to_i
    end

    step ':player_name total score should be :score' do |name, score|
      @game.process
      expect(get_player(name).calculate_score).to eq score.to_i
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
      ply.cards.map do |c|
        {
          class:    c.class,
          location: c.location,
          revealed: !!c.revealed
        }
      end
    end
    supply_cards = @game.game_state.piles.map do |p|
      p.cards.map do |c|
        {
          class:    c.class,
          location: c.location,
          revealed: !!c.revealed
        }
      end
    end
    { players: player_cards, supply: supply_cards }
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
OneCardControl.define_method(:handle_choice) do |choice|
  # First, check for the null choice
  if @cardless_button && @cardless_button[:text] == choice
    return { @key => @cardless_button[:value] }
  end

  # Otherwise, find the index requested
  choice = choice.first if choice.is_a? Array
  { @key => find_index(@player, @game_state, @scope, @question, choice) }
end
MultiCardControl.define_method(:handle_choice) do |choice|
  # First, check for choosing nothing
  return { @key => [] } if choice == []

  if choice == 'everything'
    set = @player.cards_by_location(@scope).map.with_index.select { |c, ix| filter(c) }.map(&:second)
    return { @key => set }
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
    { @key => indices }
  end
end
MultiCardChoicesControl.define_method(:handle_choice) do |choices|
  # First, check for choosing nothing
  return { @key => [] } if choices == []

  params = {}

  choices.each do |pair|
    params[find_index(@player, @game_state, @scope, @question, pair[0])] = @choices.detect { |opt| opt[0] == pair[1] }[1]
  end
  { @key => params }
end

ButtonControl.define_method(:handle_choice) do |choice|
  { @key => @values.detect { |opt| opt[0] == choice }[1] }
end

def find_index(player, game_state, scope, question, card)
  case scope
  when :hand
    player.hand_cards.index { |c| c.is_a? card }
  when :supply
    game_state.piles.index { |pile| pile.cards.first.is_a? card }
  when :deck
    player.deck_cards.index { |c| c.is_a? card }
  when :discard
    player.discarded_cards.index { |c| c.is_a? card }
  when :revealed
    player.cards_revealed_to(@question).index { |c| c.is_a? card }
  when :peeked
    player.cards_peeked_to(@question).index { |c| c.is_a? card }
  when :everywhere
    player.cards.index { |c| c.is_a? card }
  end
end