module GameEngine
  module Renaissance
    class Hideout < Card
      text "+1 Card",
           "+2 Actions",
           "Trash a card from your hand. If it's a Victory card, gain a Curse."
      action
      costs 4

      def play_as_action(played_by:)
        super

        played_by.draw_cards(1)
        played_by.grant_actions(2)

        game_state.get_journal(TrashCardJournal, from: played_by).process(game_state)
      end

      class TrashCardJournal < CommonJournals::TrashJournal
        configure question_text: "Choose a card to trash"

        def post_process
          # Grant a Curse if the trashed card was a Victory
          Helpers.gain_card_from_supply(game_state, player: player, card_class: BasicCards::Curse) if @card.victory?
        end
      end
    end
  end
end
