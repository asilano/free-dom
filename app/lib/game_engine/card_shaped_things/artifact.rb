module GameEngine
  module CardShapedThings
    class Artifact
      extend CardDecorators::BasicDecorators

      attr_reader :owner
      delegate :types, :readable_name, to: :class

      def self.comes_from(klass)
        define_method(:comes_from) { klass }
      end

      def self.readable_name
        name.demodulize.underscore.titleize
      end

      def self.raw_cost = nil

      def self.types = ["Artifact"]

      def self.randomiser? = false

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
