class Intrigue::Harem < Card
  costs 6
  treasure :cash => 2
  victory :points => 2
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..4
                              12
                            when 5..6
                              15
                            end}
  card_text "Treasure/Victory (cost: 6) - 2 Cash / 2 points"
end
