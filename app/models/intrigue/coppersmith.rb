class Intrigue::Coppersmith < Card
  costs 4
  action
  card_text "Action (cost: 4) - Copper produces an extra 1 cash this turn."
  
  def play(parent_act)
    super
    
    # Increment the count of Coppersmiths played at game scope.
    # BasicCards::Copper handles the actual value.
    game.facts_will_change!
    game.facts[:coppersmiths] ||= 0
    game.facts[:coppersmiths] += 1
    game.save!
    
    return "OK"
  end
end
