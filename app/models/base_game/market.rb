class BaseGame::Market < Card
  costs 5
  action
  card_text "Action (cost: 5) - Draw 1 card, +1 Action, +1 Buy, +1 Cash."

  def play
    super

    # Give one of everything!
    player.draw_cards(1)
    player.add_actions(1)
    player.add_buys(1)
    player.cash += 1
  end

end
