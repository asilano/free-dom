module GameEngine
  module BaseGameV2
    class Village < GameEngine::Card
      text '+1 Card',
           '+1 Action'
      action
      costs 3

      def play_as_action(played_by:)
        super

        played_by.draw_cards(1)
        played_by.grant_actions(2)
      end
    end
  end
end