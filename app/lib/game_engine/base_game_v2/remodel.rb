module GameEngine
  module BaseGameV2
    class Remodel < GameEngine::Card
      text 'Action (cost: 4)',
           'Trash a card from your hand. Gain a card costing up to 2 more than it.'
      action
      costs 4
    end
  end
end