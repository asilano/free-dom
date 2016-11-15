class BaseGame::Laboratory < Card
  costs 5
  action
  card_text "Action (cost: 5) - Draw 2 cards, +1 Action."

  def play
    super

    player.draw_cards(2)
    player.add_actions(1)
  end
end
