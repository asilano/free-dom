module GameEngine
  module Triggers
    class CardGained < Trigger
      attr_reader :filter

      def self.filter_watchers(card_gained, gained_by, gained_from, gained_to)
        @observers.select do |obs|
          obs.filter[card_gained, gained_by, gained_from, gained_to]
        end
      end

      private

      def set_options(filter: nil)
        @filter = filter || ->(*) { true }
      end
    end
  end
end
