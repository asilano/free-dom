module GameEngine
  class PlayerState
    attr_reader :user, :cards, :game_state, :game
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

    def other_players
      @game_state.players.reject { |p| p == self }
    end

    # Actors
    def draw_cards(num)
      shuffle_discard_under_deck if deck_cards.length < num && discarded_cards.present?
      drawn_cards = deck_cards.take(num)
      @game.current_journal.histories << History.new(
        "#{name} drew #{History.secret_log(private_to: user,
                                           private_msg: drawn_cards.map(&:readable_name).join(', '),
                                           public_msg: "#{drawn_cards.length} #{'card'.pluralize(drawn_cards.length)}"
                                           )}.",
        player: self,
        css_classes: %w[draw-cards]
      )
      drawn_cards.each(&:be_drawn)
    end

    def shuffle_discard_under_deck
      discards, other = cards.partition { |c| c.location == :discard }
      @cards = other + discards.shuffle(random: game_state.rng).each { |c| c.location = :deck }
      @game.current_journal.histories << History.new("#{name} shuffled their discards.",
                                                     player: self,
                                                     css_classes: %w[shuffle])
    end

    def reveal_cards(num, from:)
      num = cards_by_location(from).length if num == :all
      shuffle_discard_under_deck if from == :deck && deck_cards.length < num && discarded_cards.present?
      revealed_cards = cards_by_location(from).take(num)
      @game.current_journal.histories << History.new(
        "#{name} revealed #{revealed_cards.map(&:readable_name).join(', ')}"
      )
      revealed_cards.each(&:be_revealed)
    end
  end
end
