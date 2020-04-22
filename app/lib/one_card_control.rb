class OneCardControl < Control
  attr_reader :filter

  def initialize(opts = {})
    super
    @filter = filter_from(opts[:filter]) || ->(_card) { true }
    @cardless_button = opts[:null_choice]
  end

  def single_answer?(_game_state)
    return false unless cards_in_scope

    choices = [@cardless_button] + cards_in_scope.map { |c| @filter[c] }
    choices.count(&:itself) <= 1
  end

  def single_answer
    cards_in_scope.index { |c| @filter[c] } || @cardless_button[:value]
  end

  private

  def cards_in_scope
    case @scope
    when :hand
      @player.hand_cards
    when :deck
      @player.deck_cards.select(&:revealed?)
    when :supply
    end
  end

end
