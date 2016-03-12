class BaseGame::Smithy < Card
  costs 4
  action
  card_text "Action (cost: 4) - Draw 3 cards."

  def play
    super

    # Just draw 3 cards.
    player.draw_cards(3)

    "OK"
  end

end
