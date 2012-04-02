# GrandMarket (Action - $6) - Draw 1 Card, +1 Action, +1 Buy, +2 Cash. / You can't buy this if you have any Copper in play.

class Prosperity::GrandMarket < Card
  action
  costs 6
  card_text "Action (cost: 6) - Draw 1 Card, +1 Action, +1 Buy, +2 Cash. / You can't buy this if you have any Copper in play."
  
  def play(parent_act)
    super
    
    # Nice easy card.
    player.draw_cards(1)
    player.add_actions(1, parent_act)
    player.add_buys(1, parent_act)
    player.cash += 2
    player.save!
    
    return "OK"
  end
  
  # The Buy restriction is handled in Player#determine_controls and Player#buy
end