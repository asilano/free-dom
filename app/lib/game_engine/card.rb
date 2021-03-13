module GameEngine
  class Card
    extend CardDecorators::CardDecorators
    attr_reader :game_state
    attr_accessor :location, :player, :pile, :revealed, :peeked, :interacting_with

    delegate :game, :observe, :trigger, to: :game_state
    delegate :action?, :treasure?, :special?, :victory?, :curse?, :reaction?, :attack?, :readable_name, :types, to: :class

    # By default, 10 cards in a pile
    pile_size 10

    def self.expansions
      [GameEngine::BaseGameV2]
    end

    # The ever-present Victory cards
    BASIC_VICTORY_TYPES = %w[Estate Duchy Province Curse].map { |t| 'GameEngine::BasicCards::' + t }.freeze

    # The ever-present Treasure cards
    BASIC_TREASURE_TYPES = %w[Copper Silver Gold].map { |t| 'GameEngine::BasicCards::' + t }.freeze

    def self.basic_victory_types
      BASIC_VICTORY_TYPES.map(&:constantize)
    end

    def self.basic_treasure_types
      BASIC_TREASURE_TYPES.map(&:constantize)
    end

    def self.all_card_types
      expansions.flat_map(&:card_classes) +
        basic_victory_types + basic_treasure_types
    end

    def self.all_kingdom_cards
      expansions.flat_map(&:kingdom_cards)
    end

    def self.readable_name
      name.demodulize.underscore.titleize
    end

    def self.types
      %w[action attack curse reaction treasure victory].map do |type|
        type if send("#{type}?")
      end.compact
    end

    def initialize(game_state, pile: nil, player: nil)
      @game_state = game_state
      @pile = pile
      @player = player
    end

    def cost
      self.class.raw_cost
    end

    def player_can_buy?(player:)
      cost <= player.cash
    end

    def play_as_action(played_by:)
      @location = :play
      game.current_journal.histories << History.new("#{played_by.name} played #{readable_name}.",
                                                    player: played_by,
                                                    css_classes: types + %w[play-action])
    end

    def play_as_treasure(played_by:)
      @location = :play
      Triggers::TreasurePlayed.trigger(self, played_by)
      cash_gain = cash
      player.cash += cash_gain
      game.current_journal.histories << History.new("#{played_by.name} played #{readable_name} ($#{cash_gain}) (total: $#{played_by.cash}).",
                                                    player: played_by,
                                                    css_classes: types + %w[play-treasure])
    end

    def react(response, reacted_by:)
      game.current_journal.histories << History.new("#{reacted_by.name} reacted with #{readable_name}.",
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
      @location = :discard
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

    # Is this card (in play and) currently still doing something, so it cannot
    # be discarded? Generally, no, and subclasses will override. The obvious candidates
    # will be Durations; but more exotic examples also exist, and Throne Room-type
    # cards copying Durations track as well.
    def tracking?
      false
    end

    def inspect
      "#{readable_name}.#{Digest::MD5.base64digest(object_id.to_s)}"
    end
  end
end
