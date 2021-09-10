module GameEngine
  module BaseGameV2
    class Festival < GameEngine::Card
      text 'Action (cost: 5)',
           '+2 Actions',
           '+1 Buy',
           '+2 Cash'
      action
      costs 5

      def play_as_action(played_by:)
        super

        played_by.grant_actions(2)
        played_by.grant_buys(1)
        played_by.grant_cash(2)
      end
    end
  end
end