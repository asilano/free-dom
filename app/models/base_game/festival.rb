class BaseGame::Festival < Card
  costs 5
  action
  card_text "Action (cost: 5) - +2 Actions, +1 Buy, +2 Cash."

  def play
    super

    player.add_actions(2)
    player.add_buys(1)
    player.cash += 2
  end
end
