module GameEngine
  module BaseGameV2
    class Market < GameEngine::Card
      text '+1 Card',
           '+1 Action',
           '+1 Buy',
           '+1 Cash'
      action
      costs 5

      def play_as_action(played_by:)
        super

        played_by.draw_cards(1)
        observe
        played_by.grant_actions(1)
        played_by.grant_buys(1)
        played_by.grant_cash(1)
      end
    end
  end
end