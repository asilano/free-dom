module GameEngine
  module BaseGameV2
    class Merchant < GameEngine::Card
      text 'Action (cost: 3)',
           '+1 Card',
           '+1 Action',
           'The first time you play a Silver this turn, +1 Cash.'
      action
      costs 3
    end
  end
end