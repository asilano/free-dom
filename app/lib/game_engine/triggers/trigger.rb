module GameEngine
  module Triggers
    class Trigger
      attr_reader :effect, :filter
      attr_accessor :whenever

      def self.inherited(subclass)
        @subclasses ||= []
        @subclasses << subclass
        subclass.instance_variable_set('@observers', [])
      end

      def self.watch_for(options = {}, &block)
        stop_at = options.delete(:stop_at)
        trigger = new(options, &block)
        @observers << trigger

        if stop_at == :end_of_turn
          EndOfTurn.watch_for { @observers.delete(trigger) }
        end
        trigger
      end

      def self.trigger(*args, **kwargs)
        watchers = filter_watchers(*args, **kwargs)
        watchers.each do |w|
          ret = w.effect.call(*args, **kwargs)
          w.whenever = false if ret == :unwatch
        end
        @observers -= watchers.reject(&:whenever)
        0
      end

      def self.filter_watchers(*args, **kwargs)
        @observers.select do |obs|
          if kwargs.present?
            obs.filter[*args, **kwargs]
          else
            obs.filter[*args]
          end
        end
      end

      def self.clear_watchers
        @observers = []
        @subclasses&.each(&:clear_watchers)
      end

      private

      def initialize(options, &block)
        @whenever = options.delete(:whenever)
        @effect = block
        set_options(options)
      end

      def set_options(filter: nil)
        @filter = filter || ->(*) { true }
      end
    end
  end
end