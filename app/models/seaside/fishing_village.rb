# 7	Fishing Village	Seaside	Action - Duration	$3	+2 Actions, +1 Coin, At the start of your next turn: +1 Action, +1 Coin

class Seaside::FishingVillage < Card
  costs 3
  action :duration => true
  card_text "Action (Duration; cost: 3) - +2 Actions, +1 Cash. At the start of your next turn: +1 Action, +1 Cash."
  
  def play(parent_act)
    super
		
		# Create two new Actions
    player.add_actions(2, parent_act)

    # Add one cash (and have to save)
    player.cash += 1
    player.save!

    return "OK"
  end
  
  def end_duration(parent_act)
    super

		# Create one new Action
    player.add_actions(1, parent_act)

    # Add one cash (and have to save)
    player.cash += 1
    player.save!

    return "OK"
  end
	
end

