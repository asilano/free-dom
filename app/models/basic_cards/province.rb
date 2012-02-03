class BasicCards::Province < Card
  costs 8
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..4
                              12
                            when 5
                              15
                            when 6
                              18
                            end}
  victory :points => 6
  card_text "Victory (cost: 8) - 6 points"    
end

