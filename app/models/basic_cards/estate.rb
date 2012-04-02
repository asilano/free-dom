class BasicCards::Estate < Card
  costs 2
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..6
                              12
                            end}
  victory :points => 1
  card_text "Victory (cost: 2) - 1 point"  
end

