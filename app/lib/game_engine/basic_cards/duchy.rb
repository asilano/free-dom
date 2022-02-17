module GameEngine
  module BasicCards
    class Duchy < GameEngine::Card
      text '3 points'
      victory points: 3
      costs 5
    end
  end
end