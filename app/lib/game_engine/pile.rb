class GameEngine::Pile
  attr_reader :card_class, :cards

  def initialize(card_class)
    @card_class = card_class
    @cards = []
  end

  def fill_with(cards)
    @cards = cards
    @cards.each { |c| c.location = :pile }
  end

  def text
    @cards.first&.text || card_class.card_text
  rescue
    ''
  end
end