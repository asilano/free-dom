module GameEngine
  module BaseGameV2
    class Festival < GameEngine::Card
      text 'Action (cost: 5)',
           '+2 Actions',
           '+1 Buy',
           '+2 Cash'
      action
      costs 5
    end
  end
end