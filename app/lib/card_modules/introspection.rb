module CardModules
  module Introspection
    def self.included(base)
      base.extend ClassMethods
    end

    def cost
      self.class.raw_cost
    end

    def player_can_buy?(player:)
      cost <= player.cash
    end

    # Is this card (in play and) currently still doing something, so it cannot
    # be discarded? Generally, no, and subclasses will override. The obvious candidates
    # will be Durations; but more exotic examples also exist, and Throne Room-type
    # cards copying Durations track as well.
    def tracking?
      false
    end

    def inspect
      "#{readable_name}.#{Digest::MD5.base64digest(object_id.to_s)}"
    end

    module ClassMethods
      def readable_name
        name.demodulize.underscore.titleize
      end

      def types
        %w[action attack curse duration reaction treasure victory].map do |type|
          type if send("#{type}?")
        end.compact
      end
    end
  end
end
