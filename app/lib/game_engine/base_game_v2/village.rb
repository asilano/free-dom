module GameEngine
  module BaseGameV2
    class Village < GameEngine::Card
      text 'Action (cost: 3)',
           '+1 Card',
           '+1 Action'
      action
      costs 3
    end
  end
end