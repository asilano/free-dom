module GameEngine
  module BaseGameV2
    class Mine < GameEngine::Card
      text 'You may trash a Treasure from your hand. Gain a Treasure to your hand' \
           ' costing up to 3 more than it.'
      action
      costs 5

      def play(played_by:)
        game_state.get_journal(TrashTreasureJournal, from: played_by).process(game_state)
      end

      class TrashTreasureJournal < CommonJournals::TrashJournal
        configure question_text: 'Choose a Treasure to trash',
                  filter:        :treasure?

        def post_process
          # Ask the player to take a replacement
          game_state.get_journal(GainTreasureJournal, from: player, opts: { trashed_cost: @card_cost }).process(game_state)
        end
      end

      class GainTreasureJournal < CommonJournals::GainJournal
        configure question_text: 'Choose a Treasure to gain to hand',
                  filter:        ->(card) { card && card.treasure? && card.cost <= opts[:trashed_cost] + 3 },
                  destination:   :hand

        validation do
          valid_gain_choice(filter: ->(card) { card && card.treasure? && card.cost <= opts[:trashed_cost] + 3 })
        end
      end
    end
  end
end
