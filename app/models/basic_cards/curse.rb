class BasicCards::Curse < Card
  costs 0
  pile_size {|num_players| 10 * (num_players - 1)}
  card_text "Curse (cost: 0) - -1 points"

  # I'd like to use decorators here, but Curse is worth victory points without
  # being a victory card. 
  def points
    -1
  end
  
  def self.is_curse?
    true
  end
  
end

