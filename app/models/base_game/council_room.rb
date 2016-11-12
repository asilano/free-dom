class BaseGame::CouncilRoom < Card
  costs 5
  action
  card_text "Action (cost: 5) - Draw 4 cards, +1 Buy. Each other player draws a card."

  def play
    super

    # This player...
    player.draw_cards(4)
    player.add_buys(1)

    # ... other players
    player.other_players.each { |p| p.draw_cards(1) }
  end
end
