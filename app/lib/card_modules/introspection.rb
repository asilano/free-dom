module CardModules
  module Introspection
    def self.included(base)
      base.extend ClassMethods
    end

    def cost
      inventors = game_state.get_fact(:inventors) || 0
      (self.class.raw_cost - inventors).clamp(0..)
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

    def visible_to?(check_player)
      # Default visibility based on card location
      visible = case location
                when :deck
                  false
                when :hand, :discard
                  check_player == player
                else
                  # Probably in some variation of "in play" (enduring etc.). Default to visible
                  true
                end

      # Here, apply visibility effects
      @visibility_effects.each do |effect|
        if effect[:to] == check_player || effect[:to] == :all
          visible = effect[:visible]
        end
      end

      visible
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
