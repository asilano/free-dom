module GameEngine
  module BaseGameV2
    class Mine < GameEngine::Card
      text 'Action (cost: 5)',
           'You may trash a Treasure from your hand. Gain a Treasure to your hand' \
           ' costing up to 3 more than it.'
      action
      costs 5
    end
  end
end