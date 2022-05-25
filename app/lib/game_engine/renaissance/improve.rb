module GameEngine
  module Renaissance
    class Improve < Card
      text "+$2",
           "At the start of Clean-up, you may trash an Action card you would discard from play this turn," \
           " to gain a card costing exactly $1 more than it."
      action
      costs 3

      def play(played_by:)
        played_by.grant_cash(2)

        Triggers::StartOfCleanup.watch_for do
          game_state.get_journal(TrashActionJournal, from: played_by).process(game_state)
        end
      end

      class TrashActionJournal < CommonJournals::TrashJournal
        configure question_text: "Choose a card to Improve",
                  scope:         :play,
                  filter:        -> (card) do
                    card.action? && !card.tracking?
                  end

        def post_process
          # Ask the player to take a replacement
          game_state.get_journal(GainCardJournal, from: player, opts: { trashed_cost: @card_cost }).process(game_state)
        end
      end

      class GainCardJournal < CommonJournals::GainJournal
        configure question_text: 'Choose a card to gain',
                  filter:        ->(card) { card && card.cost == opts[:trashed_cost] + 1 }

        validation do
          valid_gain_choice(filter: ->(card) { card && card.cost == opts[:trashed_cost] + 1 })
        end
      end
    end
  end
end
