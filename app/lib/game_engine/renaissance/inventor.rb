module GameEngine
  module Renaissance
    class Inventor < Card
      text "Gain a card costing up to 4, then cards cost 1 less this turn (but not less than 0)."
      action
      costs 4

      def play(played_by:)
        game_state.get_journal(GainCardJournal, from: played_by).process(game_state)
        prev_count = game_state.get_fact(:inventors)
        game_state.set_fact(:inventors, (prev_count || 0) + 1)
      end

      class GainCardJournal < CommonJournals::GainJournal
        configure question_text: "Choose a card to gain",
                  filter:        ->(card) { card && card.cost <= 4 }

        validation do
          valid_gain_by_cost(max_cost: 4)
        end
      end
    end
  end
end
