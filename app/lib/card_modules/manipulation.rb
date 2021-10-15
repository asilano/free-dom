module CardModules
  module Manipulation
    def play_as_action(played_by:)
      @location = :play
      game.current_journal.histories << GameEngine::History.new("#{played_by.name} played #{readable_name}.",
                                                                player: played_by,
                                                                css_classes: types + %w[play-action])
    end

    def play_as_treasure(played_by:, stop_before_cash: false)
      @location = :play
      GameEngine::Triggers::TreasurePlayed.trigger(self, played_by)

      return if stop_before_cash

      cash_gain = cash
      player.cash += cash_gain
      game.current_journal.histories << GameEngine::History.new("#{played_by.name} played #{readable_name} ($#{cash_gain}) (total: $#{played_by.cash}).",
                                                                player: played_by,
                                                                css_classes: types + %w[play-treasure])
    end

    def react(_response, reacted_by:)
      game.current_journal.histories << GameEngine::History.new("#{reacted_by.name} reacted with #{readable_name}.",
                                                                player: reacted_by,
                                                                css_classes: %w[react])
    end

    # Default effect of a player gaining a card
    def be_gained_by(player, from:, to: :discard)
      from.delete(self)
      if %i[deck discard].include? to
        # Add self onto the front of the player's cards, so it's on top of the deck/discard
        player.cards.unshift(self)
      else
        player.cards << self
      end
      @player = player
      @pile = nil
      @location = to

      game_state.trigger do
        GameEngine::Triggers::CardGained.trigger(self, @player, from, to)
      end
    end

    def put_on_deck(player, from:)
      from.delete(self)

      # Add self onto the front of the player's cards, so it's on top of the deck
      player.cards.unshift(self)
      @player = player
      @location = :deck
    end

    # Default effect of a card being put into discard from wherever it is
    # (via the rules-significant word "discard")
    # Note - the discard is ordered, just like the deck, but the rules word
    # "discard" implies the player already owns it.
    def discard
      @player.cards.delete(self)
      @player.cards.unshift(self)
      old_location = @location
      @location = :discard

      game_state.trigger do
        GameEngine::Triggers::CardDiscarded.trigger(self, @player, old_location)
      end
    end

    # Default effect of a card being drawn. This is not expected to ever be overridden
    def be_drawn
      @location = :hand
    end

    # Default effect of a card being trashed.
    def trash(from:)
      from.delete(self)

      @player = nil
      @pile = nil
      @location = :trash
    end

    # Default effect of a card being revealed.
    def be_revealed
      @revealed = true
    end

    # Default effect of a card being unrevealed. This is not expected to ever be overridden
    def be_unrevealed
      @revealed = false
    end

    # Default effect of a card being looked at.
    def be_peeked
      @peeked = true
    end

    # Default effect of a card stopping being looked at. This is not expected to ever be overridden
    def be_unpeeked
      @peeked = false
    end

    def move_to_hand
      @location = :hand
    end

    # Move a card to an unusual location
    def move_to(location)
      @location = location
    end

    # Note - at time of coding, the player must own a card that is being returned to supply
    def return_to_supply(pile: nil)
      unless pile
        pile = game_state.piles.detect { |p| p.card_class == self.class }
      end
      raise InvalidJournalError, "Can't find pile to move #{readable_name} to" unless pile

      @player.cards.delete(self)
      pile.cards.unshift(self)
      @player = nil
      @pile = pile
      @location = :pile
    end
  end
end
