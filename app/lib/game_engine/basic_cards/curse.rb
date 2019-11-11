module GameEngine
  module BasicCards
    class Curse < GameEngine::Card
      text 'Curse (cost: 0)', '-1 point'
      curse
      pile_size { |num_players| 10 * (num_players - 1) }
      costs 0
    end
  end
end
