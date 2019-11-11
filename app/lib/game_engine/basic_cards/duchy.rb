module GameEngine
  module BasicCards
    class Duchy < GameEngine::Card
      text 'Victory (cost: 5)', '3 points'
      victory points: 3
      costs 5
    end
  end
end