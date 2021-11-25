module GameEngine
  module Renaissance
    class Research < Card
      text "+1 Action",
           "Trash a card from your hand. Per 1 Cash it costs, set aside a card from your deck face down (on this). At the start of your next turn, put those cards into your hand."
      action
      duration
      costs 4

      def play_as_action(played_by:)
        super

        played_by.grant_actions(1)
        game_state.get_journal(TrashCardJournal, from: played_by).process(game_state)
      end

      class TrashCardJournal < CommonJournals::TrashJournal
        configure question_text: 'Choose a card to trash'

        def post_process
          # Move trashed-cost cards face down from deck to this card

        end
      end

    end
  end
end
