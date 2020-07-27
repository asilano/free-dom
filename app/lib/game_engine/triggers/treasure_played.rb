module GameEngine
  module Triggers
    class TreasurePlayed
      @observers = []

      attr_reader :filter, :effect

      def self.watch_for(filter: nil, stop_at:, &block)
        trigger = new(filter, &block)
        @observers << trigger

        if stop_at == :end_of_turn
          EndOfTurn.watch_for { @observers.delete(trigger) }
        end
      end

      def self.trigger(treasure_played, played_by)
        watchers = @observers.select do |obs|
          obs.filter[treasure_played, played_by]
        end
        watchers.each { |w| w.effect.call }
        @observers -= watchers
      end

      private

      def initialize(filter, &block)
        @filter = filter || ->(_,_) { true }
        @effect = block
      end
    end
  end
end
