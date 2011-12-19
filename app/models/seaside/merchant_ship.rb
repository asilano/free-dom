# 22	Merchant Ship	Seaside	Action - Duration	$5	Now and at the start of your next turn: +2 Cash.

class Seaside::MerchantShip < Card
  costs 5
  action :duration => true
  card_text "Action (Duration; cost: 5) - Now and at the start of your next turn: +2 Cash."
  
  def play(parent_act)
    super
    # Add two cash (and have to save)
    player.cash += 2
    player.save!

    return "OK"
  end
  
  def end_duration(parent_act)
    super

    # Add two cash (and have to save)
    player.cash += 2
    player.save!

    return "OK"
  end
  
end

