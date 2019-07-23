module GameEngine
  module BaseGameV2
    class Vassal < GameEngine::Card
      text 'Action (cost: 3)',
           '+2 Cash',
           'Discard the top card of your deck. If it\'s an Action card, you may play it.'
      action
      costs 3
    end
  end
end