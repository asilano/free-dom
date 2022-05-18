module GameEngine
  module CardShapedThings
    module Projects
      class Sewers < Project
        text "When you trash a card other than with this, you may trash a card from your hand."
        costs 3

        def initialize(game_state)
          super

          Triggers::CardTrashed.watch_for(whenever: true) do |card, trasher|
            next unless owners.include? trasher
            next if card.facts[:sewers_trash]

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{trasher.name}.",
              player: trasher)

            game_state.get_journal(TrashCardJournal, from: trasher).process(game_state)
          end
        end

        class TrashCardJournal < CommonJournals::TrashJournal
          configure question_text: "Choose an additional card to trash",
                    allow_null: true

          def pre_observe_process
            @card.facts[:sewers_trash] = true
          end

          def post_process
            @card.facts[:sewers_trash] = false
          end
        end
      end
    end
  end
end
