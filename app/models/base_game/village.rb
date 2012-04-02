class BaseGame::Village < Card
  costs 3
  action
  card_text "Action (cost: 3) - Draw 1 card, +2 Actions."
  
  def play(parent_act)
    super
    
    # First, draw a card.
    player.draw_cards(1)
        
    # Now create two new Actions
    player.add_actions(2, parent_act)
    
    return "OK"
  end
  
end
