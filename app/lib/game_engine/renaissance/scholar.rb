module GameEngine
  module Renaissance
    class Scholar < Card
      text "Discard your hand. +7 Cards."
      action
      costs 5

      def play(played_by:)
        cards = played_by.hand_cards
        texts_for_history = cards.map(&:readable_name)
        cards.each(&:discard)
        game.current_journal.histories << History.new("#{played_by.name} discarded #{texts_for_history.join(', ')}",
                                  player:      played_by,
                                  css_classes: %w[discard])

        observe

        played_by.draw_cards(7)
      end
    end
  end
end
