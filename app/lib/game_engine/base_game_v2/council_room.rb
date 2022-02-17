module GameEngine
  module BaseGameV2
    class CouncilRoom < GameEngine::Card
      text '+4 Cards, +1 Buy',
           'Each other player draws a card.'
      action
      costs 5

      def play_as_action(played_by:)
        super

        played_by.draw_cards(4)
        observe

        played_by.grant_buys(1)

        played_by.other_players.each { |ply| ply.draw_cards(1); observe }
      end
    end
  end
end
