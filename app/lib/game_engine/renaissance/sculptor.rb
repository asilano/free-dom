module GameEngine
  module Renaissance
    class Sculptor < Card
      text "Gain a card to your hand costing up to $4. If it's a Treasure, +1 Villager."
      action
      costs 5

      def play_as_action(played_by:)
        super

        game_state.get_journal(GainCardJournal, from: played_by).process(game_state)
      end

      class GainCardJournal < CommonJournals::GainJournal
        configure question_text: 'Choose a card to gain',
                  filter:        ->(card) { card && card.cost <= 4 },
                  destination:   :hand

        validation do
          valid_gain_by_cost(max_cost: 4)
        end

        def post_process
          player.villagers += 1 if card.treasure?
        end
      end
    end
  end
end
