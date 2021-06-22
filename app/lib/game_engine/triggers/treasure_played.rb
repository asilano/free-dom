module GameEngine
  module Triggers
    class TreasurePlayed < Trigger
      attr_reader :filter

      def self.filter_watchers(treasure_played, played_by)
        @observers.select do |obs|
          obs.filter[treasure_played, played_by]
        end
      end

      private

      def set_options(filter: nil)
        @filter = filter || ->(_,_) { true }
      end
    end
  end
end
