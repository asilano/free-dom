module GameEngine
  module CardShapedThings
    module Projects
      class Cathedral < Project
        text "At the start of your turn, trash a card from your hand."
        costs 3

        def initialize(game_state)
          super

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            next unless owners.include? turn_player

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{turn_player.name}.",
                                                                     player: turn_player)
            game_state.get_journal(TrashCardJournal, from: turn_player).process(game_state)
          end
        end

        class TrashCardJournal < CommonJournals::TrashJournal
          configure question_text: "Choose a card to trash"
        end
      end
    end
  end
end
