class OneCardControl < Control
  def initialize(opts = {})
    super
    @filter = filter_from(opts[:filter]) || ->(_card) { true }
    add_cardless_button opts[:null_choice] if opts[:null_choice]
  end

  def single_answer?(_game_state)
    return false unless cards_in_scope

    choices = cardless_buttons + cards_in_scope.uniq(&:class).map { |c| filter(c) }
    choices.count(&:itself) <= 1
  end

  def single_answer
    cards_in_scope.index { |c| filter(c) } || cardless_buttons.first[:value]
  end

  private

  def cards_in_scope
    case @scope
    when :hand
      @player.hand_cards
    when :deck
      @player.deck_cards
    when :discard
      @player.discarded_cards
    when :revealed
      @player.cards_revealed_to(@question)
    when :supply
    end
  end

end
