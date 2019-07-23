module GameEngine
  module BaseGameV2
    class Workshop < GameEngine::Card
      text 'Action (cost: 3)',
           'Gain a card costing up to 4.'
      action
      costs 3
    end
  end
end