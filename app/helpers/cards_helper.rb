module CardsHelper
  def find_card(game, id)
    game.cards.where { |c| c.id == id }.first
  end

  def find_card_for_journal(cards, journal_string)
    name = /([^()]*)/.match(journal_string).captures[0].strip
    modifiers = journal_string.scan(/\(([^)]*)\)/).flatten
    position, modifiers = modifiers.partition { |m| m.match /^\d*$/ }

    return :multi_position, nil if position.length > 1
    position = position[0]
    cards.compact!

    # Identify card by position
    if position
      card = cards[position.to_i]
      ok = !card.nil?
      ok &&= name == card.readable_name
      ok &&= modifiers.all? { |m| card.modifiers.include? m }
      #raise
      if ok
        return :ok, card
      else
        return :no_match, nil
      end
    end

    candidates = cards.select do |c|
      ok = name == c.readable_name
      ok && modifiers.all? { |m| c.modifiers.include? m }
    end

    return :no_match, nil if candidates.empty?

    if candidates.map(&:modifiers).uniq.length == 1
      return :ok, candidates[0]
    else
      return :ambiguous, candidates
    end
  end
end
