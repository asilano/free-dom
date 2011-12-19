# 23	Outpost	Seaside	Action - Duration	$5	You only draw 3 cards (instead of 5) in this turn's Clean-up phase. Take an extra turn after this one. This can't cause you to take more than two consecutive turns.

class Seaside::Outpost < Card
  costs 5
  action :duration => true
  card_text "Action (Duration; cost: 5) - You only draw 3 cards (instead of 5) in this turn's Clean-up phase. Take an extra turn after this one. This can't cause you to take more than two consecutive turns."
  
  def play(parent_act)
    super
    
    # Check that the player is not prohibited an extra turn
    if !player.state.outpost_prevent && !player.state.outpost_queued
      game.histories.create!(:event => "#{player.name} will take an extra turn after this one.",
                            :css_class => "player#{player.seat}")
    else
      game.histories.create!(:event => "#{player.name} cannot take an another extra turn.",
                            :css_class => "player#{player.seat}")
    end
    
    # Even if the player can't take an extra turn, they'll still have the "draw 3" effect. So
    # mark Outpost as queued up.
    player.state.outpost_queued = true
    player.state.save!
    
    # That's it. The actual "extra turn" happens in Player#end_turn
    
    return "OK"
  end
  
  # No redefinition of end_duration - this card does nothing on the next turn.
  
end

