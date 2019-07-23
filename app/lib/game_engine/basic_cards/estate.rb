module GameEngine
  module BasicCards
    class Estate < GameEngine::Card
      text 'Victory (cost: 2)', '1 point'
      victory points: 1
      costs 2
    end
  end
end