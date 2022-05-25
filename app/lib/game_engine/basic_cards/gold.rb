module GameEngine
  module BasicCards
    class Gold < GameEngine::Card
      text "$3"
      treasure cash: 3
      pile_size 30
      costs 6
    end
  end
end