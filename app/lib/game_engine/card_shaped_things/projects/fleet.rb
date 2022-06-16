module GameEngine
  module CardShapedThings
    module Projects
      class Fleet < Project
        text "After the game ends, there's an extra round of turns just for players with this."
        costs 5

        def initialize(game_state)
          super

          Triggers::GameEnding.watch_for do |last_player|
            game_state.game.current_journal.histories << History.new("#{readable_name} round started.")

            # Seat is 1-based, so rotate(last_player.seat) puts last_player at the end
            turn_order = game_state.players.rotate(last_player.seat)

            turn_order.lazy.select { |ply| owners.include? ply }.each do |player|
              game_state.player_turn(player, "Fleet")
            end
          end
        end
      end
    end
  end
end
