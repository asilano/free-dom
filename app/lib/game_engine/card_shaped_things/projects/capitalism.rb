module GameEngine
  module CardShapedThings
    module Projects
      class Capitalism < Project
        text "During your turns, Actions with +$ amounts in their text are also Treasures."
        costs 5

        def initialize(_game_state)
          super

          Card.define_method(:types) do
            real_types = self.class.types

            # Prevent leaks in test scripts
            capitalism = game_state.card_shapeds.detect { _1.is_a? Capitalism }
            return real_types unless capitalism
            return real_types unless capitalism.owners.include? game_state.turn_player

            if real_types.include?(:action) && raw_text.include?("+$") && !real_types.include?(:treasure)
              real_types + [:treasure]
            else
              real_types
            end
          end
        end
      end
    end
  end
end
