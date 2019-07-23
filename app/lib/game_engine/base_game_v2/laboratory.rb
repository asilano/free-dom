module GameEngine
  module BaseGameV2
    class Laboratory < GameEngine::Card
      text 'Action (cost: 5)',
           '+2 Cards',
           '+1 Action'
      action
      costs 5
    end
  end
end