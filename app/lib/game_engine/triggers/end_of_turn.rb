module GameEngine
  module Triggers
    class EndOfTurn
      @observers = []

      attr_reader :effect

      def self.watch_for(&block)
        @observers << new(&block)
      end

      def self.trigger
        @observers.each { |w| w.effect.call }
        @observers.clear
      end

      private

      def initialize(&block)
        @effect = block
      end
    end
  end
end
