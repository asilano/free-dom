module GameEngine
  module Triggers
    class CardDiscarded
      include Triggerable

      attr_reader :filter

      def self.filter_watchers(card_discarded, discarded_by, discarded_from)
        @observers.select do |obs|
          obs.filter[card_discarded, discarded_by, discarded_from]
        end
      end

      private

      def set_options(filter: nil)
        @filter = filter || ->(_,_) { true }
      end
    end
  end
end
