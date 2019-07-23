module GameEngine
  module BaseGameV2
    class ThroneRoom < GameEngine::Card
      text 'Action (cost: 4)',
           'You may play an Action card from your hand twice.'
      action
      costs 4
    end
  end
end