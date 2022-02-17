module GameEngine
  module BasicCards
    class Silver < GameEngine::Card
      text '2 cash'
      treasure cash: 2
      pile_size 40
      costs 3
    end
  end
end