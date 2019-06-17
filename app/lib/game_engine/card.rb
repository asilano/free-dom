class GameEngine::Card
  extend CardDecorators
  attr_reader :player, :pile, :game, :location, :position
  delegate :readable_name, to: :class

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
end