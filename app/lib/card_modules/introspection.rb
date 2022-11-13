module CardModules
  module Introspection
    include Purchasable

    def self.included(base)
      base.class_attribute :card_types, default: []
      base.extend ClassMethods

      base.define_singleton_method(:inherited) { |subclass| subclass.card_types = [] }
    end

    delegate :readable_name, :types, :raw_text, to: :class

    %i[action attack curse duration reaction treasure victory].each do |type|
      define_method(:"#{type}?") { types.include? type }
    end

    def cost
      inventors = game_state.get_fact(:inventors) || 0

      canal = game_state.card_shapeds.detect { _1.is_a? GameEngine::CardShapedThings::Projects::Canal }
      canal_reduction = canal&.owners&.include?(game_state.turn_player) ? 1 : 0

      (self.class.raw_cost - inventors - canal_reduction).clamp(0..)
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
      check_player = game.player_for(check_player) if check_player.is_a? User

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
      def types
        card_types
      end
    end
  end
end
