module GameEngine
  module BaseGameV2
    class Cellar < GameEngine::Card
      text 'Action (cost: 2) — +1 Action',
           'Discard any number of cards, then draw that many.'
      action
      costs 2
    end
  end
end
