# 26  Wharf  Seaside  Action  $5  Now and at the start of your next turn: +2 Cards, +1 Buy.

class Seaside::Wharf < Card
  costs 5
  action :duration => true
  card_text "Action (Duration; cost: 5) - Now and at the start of your next turn: draw 2 Cards, +1 Buy."
  
  def play(parent_act)
    super
    
    # Two cards and a buy
    player.add_buys(1, parent_act)
    player.draw_cards(2)

    return "OK"
  end
  
  def end_duration(parent_act)
    super

    # Two cards and a buy
    player.add_buys(1, parent_act)
    player.draw_cards(2)

    return "OK"
  end

end

