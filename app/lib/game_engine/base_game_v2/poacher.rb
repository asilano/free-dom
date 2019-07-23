module GameEngine
  module BaseGameV2
    class Poacher < GameEngine::Card
      text 'Action (cost: 4)',
           '+1 Card',
           '+1 Action',
           '+1 Cash',
           'Discard a card per empty Supply pile.'
      action
      costs 4
    end
  end
end
