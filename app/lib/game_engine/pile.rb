class GameEngine::Pile
  attr_reader :card_class, :cards

  def initialize(card_class)
    @card_class = card_class
    @cards = []
  end

  def fill_with(cards)
    @cards = cards
  end
end