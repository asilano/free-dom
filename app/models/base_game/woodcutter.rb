class BaseGame::Woodcutter < Card
  costs 3
  action
  card_text "Action (cost: 3) - +1 Buy, +2 Cash."

  def play(parent_act)
    super

    # Give the player an additional Buy, and 2 cash.
    player.add_buys(1, parent_act)
    player.add_cash(2)

    "OK"
  end

end
