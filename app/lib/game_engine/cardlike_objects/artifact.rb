module GameEngine
  module CardlikeObjects
    class Artifact
      attr_reader :owner
      delegate :readable_name, to: :class

      def self.comes_from(klass)
        define_method(:comes_from) { klass }
      end

      def self.text(*lines)
        str = lines.join("\n")
        define_method(:text) { str }
        define_singleton_method(:card_text) { str }
      end

      def self.readable_name
        name.demodulize.underscore.titleize
      end

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
