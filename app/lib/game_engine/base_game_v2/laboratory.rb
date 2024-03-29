module GameEngine
  module BaseGameV2
    class Laboratory < GameEngine::Card
      text '+2 Cards',
           '+1 Action'
      action
      costs 5

      def play(played_by:)
        played_by.draw_cards(2)
        played_by.grant_actions(1)
      end
    end
  end
end
