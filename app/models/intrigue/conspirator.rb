class Intrigue::Conspirator < Card
  costs 4
  action
  card_text "Action (cost: 4) - +2 Cash. If you've played 3 or more Actions this turn, " +
            "+1 Action, draw 1 card."
            
  def play(parent_act)
    super
    
    # Add the cash
    player.add_cash(2)
    
    # Check how many actions have been played this turn. We should be guaranteed
    # that game.facts[:actions_played] exists, because Conspirator is in the
    # game.
    if game.facts.include?(:actions_played) && game.facts[:actions_played] >= 3
      player.add_actions(1, parent_act)
      player.draw_cards(1)
    end
    
    return "OK"
  end
end
