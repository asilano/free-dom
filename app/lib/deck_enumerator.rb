class DeckEnumerator
  include Enumerable
  def self.for(player)
    new(player)
  end

  def each
    @player.deck_cards.each { |card| yield card }
    old_length = @player.deck_cards.length
    @player.shuffle_discard_under_deck
    @player.deck_cards[old_length..-1].each { |card| yield card }
  end

  private

  def initialize(player)
    @player = player
  end
end
