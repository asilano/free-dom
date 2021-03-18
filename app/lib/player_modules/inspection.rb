module PlayerModules
  module Inspection
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

    def revealed_cards
      cards.select(&:revealed)
    end

    def peeked_cards
      cards.select(&:peeked)
    end

    def cards_revealed_to(question)
      revealed_cards.select { |c| c.interacting_with == question }
    end

    def cards_peeked_to(question)
      peeked_cards.select { |c| c.interacting_with == question }
    end

    def other_players
      @game_state.players.reject { |p| p == self }
    end
  end
end