module GameEngine
  module CardlikeObjects
    class Artifact
      attr_reader :owner

      def initialize(game_state)
        @owner = nil
        @game_state = game_state
      end

      def give_to(player)
        @owner = player
      end

      def owned_by?(player)
        @owner == player
      end
    end
  end
end
