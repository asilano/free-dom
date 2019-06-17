module GameEngine
  module BasicCards
    class Curse < GameEngine::Card
      curse
      pile_size { |num_players| 10 * (num_players - 1) }
      costs 0
    end
  end
end
