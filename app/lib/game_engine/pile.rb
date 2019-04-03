class GameEngine::Pile
  attr_reader :card_class

  def initialize(card_class)
    @card_class = card_class
  end
end