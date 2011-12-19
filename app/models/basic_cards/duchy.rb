class BasicCards::Duchy < Card
  costs 5
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..6
                              12
                            end}
  victory :points => 3
  card_text "Victory (cost: 5) - 3 points"
end

