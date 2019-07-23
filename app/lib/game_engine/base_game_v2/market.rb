module GameEngine
  module BaseGameV2
    class Market < GameEngine::Card
      text 'Action (cost: 5)',
           '+1 Card',
           '+1 Action',
           '+1 Buy',
           '+1 Cash'
      action
      costs 5
    end
  end
end