module GameEngine
  module BaseGameV2
    class Smithy < GameEngine::Card
      text 'Action (cost: 4)',
           '+3 Cards'
      action
      costs 4
    end
  end
end