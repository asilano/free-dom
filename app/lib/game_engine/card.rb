class GameEngine::Card
  delegate :readable_name, to: :class

  def self.expansions
    [GameEngine::BaseGameV2]
  end

  def self.readable_name
    name.demodulize.underscore.titleize
  end
end