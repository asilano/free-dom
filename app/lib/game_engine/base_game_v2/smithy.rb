module GameEngine
  module BaseGameV2
    class Smithy < GameEngine::Card
      text 'Action (cost: 4)',
           '+3 Cards'
      action
      costs 4

      def play_as_action(played_by:)
        super

        played_by.draw_cards(3)
      end
    end
  end
end