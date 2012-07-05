# Colony (Victory - $11) - 10 VP

class Prosperity::Colony < Card
  costs 11
  victory :points => 10
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
  card_text "Victory (cost: 11) - 10 points"                          
end