module GameEngine
  module BasicCards
    class Province < GameEngine::Card
      text '6 points'
      victory points: 6
      pile_size do |num_players|
        case num_players
        when 2
          8
        when 3..4
          12
        else
          3 * num_players
        end
      end
      costs 8
    end
  end
end