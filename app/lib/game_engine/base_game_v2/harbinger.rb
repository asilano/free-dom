module GameEngine
  module BaseGameV2
    class Harbinger < GameEngine::Card
      text 'Action (cost: 3)',
           '+1 Card',
           '+1 Action',
           'Look through your discard pile. You may put a card from it onto your deck.'
      action
      costs 3
    end
  end
end