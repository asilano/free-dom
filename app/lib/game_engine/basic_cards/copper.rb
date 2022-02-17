module GameEngine
  module BasicCards
    class Copper < GameEngine::Card
      text '1 cash'
      treasure cash: 1
      pile_size 60
      costs 0
    end
  end
end
