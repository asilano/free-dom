module GameEngine
  module Renaissance
    class Recruiter < Card
      text "+2 Cards",
           "Trash a card from your hand. +1 Villager per $1 it costs."
      action
      costs 5

      def play_as_action(played_by:)
        super

        played_by.draw_cards(3)
        game_state.get_journal(TrashCardJournal, from: played_by, opts: { research: self }).process(game_state)
      end

      class TrashCardJournal < CommonJournals::TrashJournal
        configure question_text: 'Choose a card to trash'

        def post_process
          player.villagers += @card_cost
          @histories << History.new("#{player.name} gained #{@card_cost} Villagers.",
                                    player: player)
        end
      end
    end
  end
end
