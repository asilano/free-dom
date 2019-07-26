module GameEngine
  class Card
    extend CardDecorators
    attr_reader :player, :pile, :game
    attr_accessor :location
    delegate :action?, :treasure?, :special?, :victory?, :curse?, :reaction?, :attack?, :readable_name, to: :class

    # By default, 10 cards in a pile
    pile_size 10

    def self.expansions
      [GameEngine::BaseGameV2]
    end

    def self.readable_name
      name.demodulize.underscore.titleize
    end

    def self.types
      %w[action attack curse reaction treasure victory].map do |type|
        type if send("#{type}?")
      end.compact
    end

    def cost
      self.class.raw_cost
    end

    def player_can_buy?(player:)
      cost <= player.cash
    end

    # Default effect of a player gaining a card
    def be_gained_by(player, from:)
      from.delete(self)
      player.cards << self
      @location = :discard
    end

    # Default effect of a card being put into discard from wherever it is
    # (via the rules-significant word "discard")
    def discard
      @location = :discard
    end

    # Default effect of a card being drawn. This is not expected to ever be overridden
    def be_drawn
      @location = :hand
    end

    # Is this card (in play and) currently still doing something, so it cannot
    # be discarded? Generally, no, and subclasses will override. The obvious candidates
    # will be Durations; but more exotic examples also exist, and Throne Room-type
    # cards copying Durations track as well.
    def tracking?
      false
    end
  end
end
