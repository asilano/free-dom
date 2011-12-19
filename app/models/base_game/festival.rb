class BaseGame::Festival < Card
  costs 5
  action
  card_text "Action (cost: 5) - +2 Actions, +1 Buy, +2 Cash."
  
  def play(parent_act)
    super
    
    player.add_actions(2, parent_act)
    player.add_buys(1, parent_act)
    player.add_cash(2)
    
    return "OK"
  end
end
