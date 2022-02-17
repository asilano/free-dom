module GameEngine
  module BaseGameV2
    class Workshop < GameEngine::Card
      text 'Gain a card costing up to 4.'
      action
      costs 3

      def play_as_action(played_by:)
        super

        game_state.get_journal(GainCardJournal, from: played_by).process(game_state)
      end

      class GainCardJournal < CommonJournals::GainJournal
        configure question_text: 'Choose a card to gain',
                  filter:        ->(card) { card && card.cost <= 4 }

        validation do
          valid_gain_by_cost(max_cost: 4)
        end
      end
    end
  end
end
