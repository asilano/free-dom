module GameEngine
  class Card
    extend CardDecorators
    attr_reader :player, :pile, :game, :location, :position
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
      player.discarded_cards << self
    end
  end
end