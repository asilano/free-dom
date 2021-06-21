module GameEngine
  module Triggers
    module Triggerable
      extend ActiveSupport::Concern

      included do
        @observers = []
        attr_reader :effect
        attr_accessor :whenever
      end

      class_methods do
        def watch_for(options = {}, &block)
          stop_at = options.delete(:stop_at)
          trigger = new(options, &block)
          @observers << trigger

          if stop_at == :end_of_turn
            EndOfTurn.watch_for { @observers.delete(trigger) }
          end
          trigger
        end

        def trigger(*args, **kwargs)
          watchers = filter_watchers(*args, **kwargs)
          watchers.each do |w|
            ret = w.effect.call(*args, **kwargs)
            w.whenever = false if ret == :unwatch
          end
          @observers -= watchers.reject(&:whenever)
        end

        def filter_watchers(_)
          @observers
        end
      end

      private

      def initialize(options, &block)
        @whenever = options.delete(:whenever)
        @effect = block
        set_options(options)
      end

      def set_options(_options); end
    end
  end
end