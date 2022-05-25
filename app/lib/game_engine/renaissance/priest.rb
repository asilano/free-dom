module GameEngine
  module Renaissance
    class Priest < Card
      text "+$2",
           "Trash a card from your hand.",
           "For the rest of this turn, when you trash a card, +$2."
      action
      costs 4

      def play(played_by:)
        played_by.grant_cash(2)
        game_state.get_journal(TrashCardJournal, from: played_by).process(played_by)

        my_hand_filter = ->(_, _, _, trashed_by) { trashed_by == played_by }
        Triggers::CardTrashed.watch_for(filter: my_hand_filter, whenever: true, stop_at: :end_of_turn) do
          played_by.grant_cash(2)
          game.current_journal.histories << History.new("#{played_by} gained $2 due to Priest (total: $#{played_by.cash}).",
                                                        player: played_by)
        end
      end

      class TrashCardJournal < CommonJournals::TrashJournal
        configure question_text: "Choose a card to trash"
      end
    end
  end
end
