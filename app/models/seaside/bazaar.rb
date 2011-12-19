class Seaside::Bazaar < Card
  costs 5
  action
  card_text "Action (cost: 5) - Draw 1 card, +2 Actions, +1 Cash."
  
  def play(parent_act)
    super
    
    # First, draw a card.
    player.draw_cards(1)        
        
    # Now create two new Actions
    player.add_actions(2, parent_act)

    # And the coin.    
    player.cash += 1

    # You need to do this if you did something like player.cash += 4 directly
    player.save!

    return "OK"
  end
  
end
