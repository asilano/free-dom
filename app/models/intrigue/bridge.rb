class Intrigue::Bridge < Card
  costs 4
  action
  card_text "Action (cost: 4) - +1 Buy, +1 Cash. All cards cost 1 less this turn, but not less than 0."
  
  def play(parent_act)
    super
    
    # Add the Buy action, and the cash.
    player.add_buys(1, parent_act)
    player.add_cash(1)
    
    # Apply the discount, which is handled by card_decorators.rb
    game.facts_will_change!
    game.facts[:bridges] ||= 0
    game.facts[:bridges] += 1
    game.save!
    
    return "OK"
  end
end
