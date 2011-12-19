class Intrigue::GreatHall < Card
  costs 3
  action
  victory :points => 1
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..4
                              12
                            when 5..6
                              15
                            end}
  card_text "Action/Victory (cost: 3) - Draw 1 card, +1 Action. / 1 point."
  
  def play(parent_act)
    super
    
    # Just draw a card and add an action
    player.draw_cards(1)
    player.add_actions(1, parent_act)
    
    return "OK"
  end
  
end
