module GameEngine
  module BasicCards
    class Gold < GameEngine::Card
      text 'Treasure (cost: 6)', '3 cash'
      treasure cash: 3
      pile_size 30
      costs 6
    end
  end
end