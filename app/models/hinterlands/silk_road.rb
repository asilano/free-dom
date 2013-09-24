class Hinterlands::SilkRoad < Card
  victory {player.cards.select(&:is_victory?).count / 4}
  costs 4
  card_text "Victory (cost: 4) - Worth 1 point for every 4 Victory cards in your deck (round down)."
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..6
                              12
                            end}
end