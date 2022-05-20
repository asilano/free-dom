module GameEngine
  module BaseGameV2
    class Smithy < GameEngine::Card
      text '+3 Cards'
      action
      costs 4

      def play(played_by:)
        played_by.draw_cards(3)
      end
    end
  end
end