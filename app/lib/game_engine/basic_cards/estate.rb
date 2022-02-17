module GameEngine
  module BasicCards
    class Estate < GameEngine::Card
      text '1 point'
      victory points: 1
      costs 2
    end
  end
end