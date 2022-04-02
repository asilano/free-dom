module GameEngine
  module CardlikeObjects
    module Artifacts
      class Key < Artifact
        comes_from Renaissance::Treasurer
        text "At the start of your turn, +$1."

        def initialize(game_state)
          super(game_state)

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            next unless turn_player == owner

            owner.grant_cash(1)
            game_state.game.current_journal.histories << History.new("#{owner.name} gained $1 from Key.",
                                                                     player: owner)
          end
        end
      end
    end
  end
end
