module GameEngine
  module CardShapedThings
    module Artifacts
      class TreasureChest < Artifact
        comes_from Renaissance::Swashbuckler
        text "At the start of your Buy phase, gain a Gold."

        def initialize(game_state)
          super

          Triggers::StartOfBuyPhase.watch_for(whenever: true) do |turn_player|
            next unless turn_player == @owner

            Helpers.gain_card_from_supply(game_state, player: @owner, card_class: BasicCards::Gold)
          end
        end
      end
    end
  end
end