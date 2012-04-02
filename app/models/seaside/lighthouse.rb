# 3	Lighthouse	Seaside	Action - Duration	$2	+1 Action, Now and at the start of your next turn: +1 Coin. - While this is in play, when another player plays an Attack card, it doesn't affect you.

class Seaside::Lighthouse < Card
  costs 2
  action :duration => true
  card_text "Action (Duration; cost: 2) - +1 Action. Now and at the start of your next turn: +1 Cash. - While this is in play, when another player plays an Attack card, it doesn't affect you."

	# Note, the defence part is handled by the card_decorators.rb
	# because the player does not get to choose, nor is it a reaction

  def play(parent_act)
    super
		# +1 action
		player.add_actions(1, parent_act)
    # Add one cash (and have to save)
    player.cash += 1
    player.save!
    return "OK"
	end

  def end_duration(parent_act)
    super
    # Add one cash (and have to save)
    player.cash += 1
    player.save!
    return "OK"
  end

end

