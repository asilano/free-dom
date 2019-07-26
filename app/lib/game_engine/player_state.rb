module GameEngine
  class PlayerState
    attr_reader :user, :cards
    attr_accessor :seat, :actions, :buys, :cash

    def initialize(user, game_state)
      @user = user
      @game_state = game_state
      @game = game_state.game
      @cards = []
    end

    def name
      @user.name
    end

    # Inspectors
    def cards_by_location(location)
      @cards.select { |c| c.location == location }
    end

    def deck_cards
      cards_by_location(:deck)
    end

    def hand_cards
      cards_by_location(:hand)
    end

    def played_cards
      cards_by_location(:play)
    end

    def discarded_cards
      cards_by_location(:discard)
    end

    # Actors
    def draw_cards(num)
      shuffle_discard_under_deck if deck_cards.length < num && discarded_cards.present?
      drawn_cards = deck_cards.take(num)
      @game.current_journal.histories << History.new(
        "#{name} drew {#{user.id}?#{drawn_cards.map(&:readable_name).join(', ')}|#{drawn_cards.length} #{'card'.pluralize(drawn_cards.length)}}.",
        player: self
      )
      drawn_cards.each(&:be_drawn)
    end

    def shuffle_discard_under_deck
      discards, other = cards.partition { |c| c.location == :discard }
      @cards = other + discards.shuffle.each { |c| c.location = :deck }
      @game.current_journal.histories << History.new("#{name} shuffled their discards.",
                                                     player: self)
    end
  end
end
