module GameEngine
  module Cornucopia
    class FortuneTeller < Card
      text "+$2",
           "Each other player reveals cards from the top of their deck until they reveal " \
           "a Victory card or a Curse. They put it on top and discard the rest."
      action
      costs 3

      def play(played_by:)
        launch_attack(victims: played_by.other_players)
      end

      def attack(victim:)

      end
    end
  end
end
