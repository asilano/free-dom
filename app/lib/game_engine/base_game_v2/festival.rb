module GameEngine
  module BaseGameV2
    class Festival < GameEngine::Card
      text "+2 Actions",
           "+1 Buy",
           "+$2"
      action
      costs 5

      def play(played_by:)
        played_by.grant_actions(2)
        played_by.grant_buys(1)
        played_by.grant_cash(2)
      end
    end
  end
end
