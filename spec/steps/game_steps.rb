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

    step 'the kingdom contains :cards' do |cards|
      kingdom_journal = @game.journals.where(type: 'GameEngine::ChooseKingdomJournal').first
      list = cards.map(&:to_s) + kingdom_journal.params['card_list']
      kingdom_journal.params['card_list'] = list.uniq.take 10
      kingdom_journal.save
    end

    step ':name(\'s) hand contains :cards' do |name, cards|
      player = get_player(name == 'my' ? 'I' : name)
      make_journal(user: player.user,
                   type: GameEngine::HackJournal,
                   params: { scope: :hand,
                             action: :set,
                             cards: cards.map(&:to_s) })
    end
  end

  module ActionSteps
    step ':name choose(s) :cards in my/his/her/the :scope' do |name, cards, scope|
      user = get_player(name).user
      controls = @question.controls_for(user, @game.game_state)
      scope = scope.to_sym
      expect(controls).to include(have_attributes(scope: scope))
      control = controls.detect { |c| c.scope == scope }
      make_journal(user: user,
                   type: @question.journal_type,
                   params: control.handle_choice(cards))
    end
  end

  module CheckSteps
    step ':name should need to :question' do |name, question|
      @game.process
      @question = @game.question

      expect(@question.player).to be get_player(name)
      expect(@question.text(@game.game_state)).to be == question
    end

    step ':name(\'s) hand should contain :cards' do |name, cards|
      @game.process
      player = get_player(name == 'my' ? 'I' : name)
      expect(player.hand_cards.map { |c| c.class.to_s }).to match_array(cards.map(&:to_s))
    end

    step ':name should have :cards in play' do |name, cards|
      @game.process
      player = get_player(name)
      expect(player.played_cards.map { |c| c.class.to_s }).to match_array(cards.map(&:to_s))
    end

    step 'cards should move as follows:' do
      # Process all but the last-added journal
      @game.journals.last.ignore = true
      @game.process

      # Take a record of the cards in the game at this time.
      @cards_before = extract_game_cards

      # Unignore the last-added journal
      @game.journals.last.ignore = false
    end

    step 'these card moves should happen' do
      @game.process
      cards_now = extract_game_cards
      cards_now[:players].each.with_index do |cards, ix|
        expect(cards).to eq @cards_before[:players][ix]
      end
      cards_now[:supply].each.with_index do |cards, ix|
        expect(cards).to eq @cards_before[:supply][ix]
      end
    end

    step 'cards should not move' do
      send 'cards should move as follows:'
      send 'these card moves should happen'
    end

    step ':name should discard :cards from/in( my/his/her) :location' do |name, cards, location|
      players_cards = cards_for_player(name, location: location)
      if cards == 'everything'
        players_cards.each { |c| c[:location] = :discard }
      else
        cards.each do |type|
          card = players_cards.delete_at(players_cards.index { |c| c.is_a? == type })
          card[:location] = :discard
        end
      end
    end

    step ':name should draw :count card(s)' do |name, count|
      players_cards = cards_for_player(name, location: :deck)
      if players_cards.count < count
        # Not enough to draw. "Shuffle" the discards
        shuffle_discard_under_deck(cards_for_player(name))
        players_cards = cards_for_player(name, location: :deck)
      end

      players_cards.take(count).each { |c| c[:location] = :hand }
    end

    step ':name should gain :cards' do |name, cards|
      send ':name should gain :cards from :source to my/his/her :destination', name, cards, 'supply', 'discard'
    end

    step ':name should gain :cards to my/his/her :destination' do |name, cards, destination|
      send ':name should gain :cards from :source to my/his/her :destination', name, cards, 'supply', destination
    end

    step ':name should gain :cards from :source to my/his/her :destination' do |name, cards, source, destination|
      players_cards = cards_for_player(name)
      cards.each do |card|
        if source == 'supply'
          pile = @cards_before[:supply].detect { |p_cards| p_cards.first[:class] == card }
          pile.delete_at(0)
        end
        players_cards << { class: card, location: destination.to_sym }
      end
    end

    step ':name should move :cards from my/his/her :source to my/his/her :destination' do |name, cards, source, destination|
      players_cards = cards_for_player(name)
      cards.each do |card|
        instance_ix = players_cards.index { |c| c[:class] == card && c[:location] == source.to_sym }
        instance = players_cards[instance_ix]
        instance[:location] = destination.to_sym
        if destination == 'deck'
          players_cards.delete_at(instance_ix)
          players_cards.unshift(instance)
        end
      end
    end

    step ':name :whether_to be able to choose the :cards pile(s)' do |name, should, cards|
      controls = @question.controls_for(get_player(name).user, @game.game_state)
      control = controls.detect { |c| c.scope == :supply }
      can_pick = cards.map do |card|
        pile = @game.game_state.piles.detect { |p| p.cards.first.is_a? card }
        pile && control.filter[pile.cards.first]
      end

      expect(can_pick).to all(should ? be_truthy : be_falsey)
    end
  end

  def get_player(name)
    name.replace('Alan') if name == 'I'
    @game.process unless @game.game_state
    @game.game_state.players[PLAYER_NAMES.index(name)]
  end

  def extract_game_cards
    player_cards = @game.game_state.players.map do |ply|
      ply.cards.map { |c| { class: c.class, location: c.location } }
    end
    supply_cards = @game.game_state.piles.map do |p|
      p.cards.map { |c| { class: c.class, location: c.location } }
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
    cards.replace(other + discards.shuffle.each { |c| c[:location] = :deck })
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
  case @scope
  when :hand
    card_ix = @player.hand_cards.index { |c| c.is_a? choice }
    { @key => card_ix }
  when :supply
    pile_ix = @game_state.piles.index { |pile| pile.cards.first.is_a? choice }
    { @key => pile_ix }
  end
end
MultiCardControl.define_method(:handle_choice) do |choice|
  # First, check for choosing nothing
  return { @key => [] } if choice == []

  if choice == 'everything'
    set = @player.cards_by_location(@scope).map.with_index.select { |c, ix| @filter[c] }.map(&:second)
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
