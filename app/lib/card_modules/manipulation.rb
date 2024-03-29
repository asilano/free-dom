module CardModules
  module Manipulation
    def location=(value)
      @location = value
      @visibility_effects.clear
      be_unrevealed
    end

    def play_card(played_by:)
      self.location = :play
      self.played_this_turn = true
      game.current_journal.histories << GameEngine::History.new("#{played_by.name} played #{readable_name}.",
                                                                player: played_by,
                                                                css_classes: types + %w[play])

      GameEngine::Triggers::ActionPlayed.trigger(self, played_by) if action?
      GameEngine::Triggers::TreasurePlayed.trigger(self, played_by) if treasure?

      play(played_by: played_by)

      GameEngine::Triggers::AfterActionPlayed.trigger(self, played_by) if action?

      if treasure?
        game.current_journal.histories << GameEngine::History.new("(total: $#{played_by.cash}).",
        player: played_by,
        css_classes: types + %w[play])
      end
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
      self.location = to

      game_state.trigger do
        GameEngine::Triggers::CardGained.trigger(self, @player, from, to)
      end
    end

    def put_on_deck(player, from:)
      from.delete(self)

      # Add self onto the front of the player's cards, so it's on top of the deck
      player.cards.unshift(self)
      @player = player
      self.location = :deck
    end

    # Default effect of a card being put into discard from wherever it is
    # (via the rules-significant word "discard")
    # Note - the discard is ordered, just like the deck, but the rules word
    # "discard" implies the player already owns it.
    def discard
      @player.cards.delete(self)
      @player.cards.unshift(self)
      old_location = @location
      self.location = :discard

      game_state.trigger do
        GameEngine::Triggers::CardDiscarded.trigger(self, @player, old_location)
      end
    end

    # Default effect of a card being drawn. This is not expected to ever be overridden
    def be_drawn
      self.location = :hand
    end

    # Default effect of a card being trashed.
    def trash(from:, by: @player)
      from.delete(self)

      player_was, @player = @player, nil
      @pile = nil
      self.location = :trash
      game_state.trashed_cards << self

      game_state.trigger do
        GameEngine::Triggers::CardTrashed.trigger(self, player_was, from, by)
      end
    end

    # Add a visibility effect to the card
    def add_visibility_effect(source, to:, visible:)
      @visibility_effects << {
        source: source,
        to: to,
        visible: visible
      }
    end

    # Default effect of a card being revealed.
    def be_revealed
      @revealed = true

      game_state.trigger do
        GameEngine::Triggers::CardRevealed.trigger(self, @player, @location)
      end
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
      self.location = :hand
    end

    # Move a card to an unusual location
    def move_to(location)
      self.location = location
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
      self.location = :pile
    end
  end
end
