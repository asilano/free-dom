module GameEngine
  module CardShapedThings
    module Projects
      class Fair < Project
        text "At the start of your turn, +1 Buy."
        costs 4

        def initialize(game_state)
          super

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            next unless owners.include? turn_player

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{turn_player.name}.",
                                                                     player: turn_player)
            turn_player.grant_buys(1)
          end
        end
      end
    end
  end
end
