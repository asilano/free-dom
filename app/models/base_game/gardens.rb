class BaseGame::Gardens < Card
  costs 4
  pile_size { |num_players|  case num_players
                            when 1..2
                              8
                            when 3..6
                              12
                            end }
  victory { player.cards.count / 10 }
  card_text "Victory (cost: 4) - Worth 1 point for every 10 cards in your deck (rounded down)."
end

