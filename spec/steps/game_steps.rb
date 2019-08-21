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
  end

  module ActionSteps
    step 'I choose :choice in my/his/her/the :scope' do |choice, scope|
      user = @user_alan
      controls = @question.controls_for(user, @game.game_state)
      scope = scope.to_sym
      expect(controls).to include(have_attributes(scope: scope))
      control = controls.detect { |c| c.scope == scope }
      make_journal(user: user,
                   type: @question.journal_type,
                   params: control.handle_choice(choice))
    end

    def make_journal(**kwargs)
      @game.journals.create(order: @game.journals.map(&:order).max + 1, **kwargs)
    end
  end

  module CheckSteps
    step ':name should need to :question' do |name, question|
      @game.process
      @question = @game.question

      expect(@question.player).to be get_player(name)
      expect(@question.text(@game.game_state)).to be == question
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

    step ':name should discard :cards from/in (my/his/her) :location' do |name, cards, location|
      players_cards = cards_for_player(name, location: location)
      if cards == 'everything'
        players_cards.each { |c| c[:location] = :discard }
      else
        cards.split(/,\s*/).each do |type|
          card = players_cards.delete_at(players_cards.index { |c| c[:class].readable_name == type })
          card[:location] = :discard
        end
      end
    end

    step ':name should draw :count cards' do |name, count|
      players_cards = cards_for_player(name, location: :deck)
      if players_cards.count < count
        # Not enough to draw. "Shuffle" the discards
        shuffle_discard_under_deck(cards_for_player(name))
        players_cards = cards_for_player(name, location: :deck)
      end

      players_cards.take(count).each { |c| c[:location] = :hand }
    end
  end

  def get_player(name)
    name.replace('Alan') if name == 'I'
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
end

# Monkey-patch in methods for each control type to handle being told what to do
# Each returns the params for the journal that will be created.
OneCardControl.define_method(:handle_choice) do |choice|
  # First, check for the null choice
  if @cardless_button && @cardless_button[:text] == choice
    { @key => @cardless_button[:value] }
  end
end
MultiCardControl.define_method(:handle_choice) do |choice|
  # First, check for choosing nothing
  return { @key => [] } if choice == 'nothing'
end