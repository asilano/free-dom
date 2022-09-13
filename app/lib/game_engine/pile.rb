class GameEngine::Pile
  attr_reader :card_class, :cards, :tokens

  def initialize(card_class)
    @card_class = card_class
    @cards = []
    @tokens = []
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

  def html_safe_text
    @cards.first&.html_safe_text || card_class.html_safe_card_text
  rescue
    ''
  end
end
