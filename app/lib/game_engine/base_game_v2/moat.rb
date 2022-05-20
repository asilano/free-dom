module GameEngine
  module BaseGameV2
    class Moat < GameEngine::Card
      text '+2 Cards',
           :hr,
           'When another player plays an Attack card, you may first reveal this' \
           ' from your hand, to be unaffected by it.'
      action
      reaction from: :hand, to: :attack#, once_only: true
      costs 2

      def play(played_by:)
        played_by.draw_cards(2)
        observe
      end

      def react(response, reacted_by:)
        super
        response[:prevented] = true
      end
    end
  end
end