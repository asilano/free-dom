# Quarry (Treasure - $4) - 1 Cash. While this is in play, Action cards cost 2 less, but not less than 0.

class Prosperity::Quarry < Card
  treasure :cash => 1
  costs 4
  card_text "Treasure (cost: 4) - 1 Cash. While this is in play, Action cards cost 2 less, but not less than 0."
  
  # Handled in Card#cost
end