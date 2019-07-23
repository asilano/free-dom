module GameEngine
  module BaseGameV2
    class Moat < GameEngine::Card
      text 'Action/Reaction (cost: 2)',
           '+2 Cards',
           'When another player plays an Attack card, you may first reveal this' \
           ' from your hand, to be unaffected by it.'
      action
      reaction
      costs 2
    end
  end
end