class BaseGame::Market < Card
  costs 5
  action
  card_text "Action (cost: 5) - Draw 1 card, +1 Action, +1 Buy, +1 Cash."
  
  def play(parent_act)
    super
    
    # Give one of everything!
    player.draw_cards(1)
    player.add_actions(1, parent_act)
    player.add_buys(1, parent_act)
    player.add_cash(1)
    
    return "OK"
  end
  
end
