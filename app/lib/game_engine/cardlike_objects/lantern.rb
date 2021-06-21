module GameEngine
  module CardlikeObjects
    class Lantern
      def initialize(game_state)
        game_state.set_fact(:lantern_owner, nil)
        game_state.access_fact(:lantern_owner)
      end
    end
  end
end
