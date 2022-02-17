module GameEngine
  module BaseGameV2
    class Remodel < GameEngine::Card
      text 'Trash a card from your hand. Gain a card costing up to 2 more than it.'
      action
      costs 4

      def play_as_action(played_by:)
        super

        game_state.get_journal(TrashCardJournal, from: played_by).process(game_state)
      end

      class TrashCardJournal < CommonJournals::TrashJournal
        configure question_text: 'Choose a card to trash'

        def post_process
          # Ask the player to take a replacement
          game_state.get_journal(GainCardJournal, from: player, opts: { trashed_cost: @card_cost }).process(game_state)
        end
      end

      class GainCardJournal < CommonJournals::GainJournal
        configure question_text: 'Choose a card to gain',
                  filter:        ->(card) { card && card.cost <= opts[:trashed_cost] + 2 }

        validation do
          valid_gain_choice(filter: ->(card) { card && card.cost <= opts[:trashed_cost] + 2 })
        end
      end
    end
  end
end
