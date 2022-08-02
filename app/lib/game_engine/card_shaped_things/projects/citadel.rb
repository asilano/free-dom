module GameEngine
  module CardShapedThings
    module Projects
      class Citadel < Project
        text "The first time you play an Action card during each of your turns, replay it afterwards."
        costs 8

        def initialize(game_state)
          super

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            Triggers::AfterActionPlayed.watch_for(stop_at: :end_of_turn) do |card, played_by|
              next unless owners.include?(played_by) && played_by == turn_player

              game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{played_by.name}.",
                player: played_by)

              card.play_card(played_by: played_by)
            end
          end
        end
      end
    end
  end
end
