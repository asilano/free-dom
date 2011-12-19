class Intrigue::MiningVillage < Card
  costs 4
  action
  card_text "Action (cost: 4) - Draw 1 card, +2 Actions. You may trash this card immediately; if you do, +2 cash."
  
  def play(parent_act)
    super
    
    # Simple stuff first
    player.draw_cards(1)
    new_parent_act = player.add_actions(2, parent_act)
    
    # Now, optionally trashing this card should be fairly straightforward, but
    # it's explicitly ruled that you can't trash it twice if you've used
    # Throne Room or King's Court. 
    # If this is not the last ThroneRoomed or KingsCourted copy of this card, then parent_act will 
    # be another one. Only add the trash action if it isn't.
    if parent_act.expected_action !~ /resolve_.*(ThroneRoom|KingsCourt).*_playaction;type=#{self.class};id=#{id}/
      new_parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                 :text => "Optionally trash Mining Village",
                                 :player => player,
                                 :game => game)                                 
    end
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "trash"
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :name => "trash",
                             :label => "#{readable_name}:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "trash"},
                             :options => [{:text => "Trash",
                                           :choice => "trash"},                            
                                          {:text => "Don't trash",
                                           :choice => "keep"}]
                            }]
    end    
  end
  
  def resolve_trash(ply, params, parent_act)
    # We expect to have a :choice parameter, either "trash" or "keep"
    if (not params.include? :choice) or
       (not params[:choice].in? ["trash", "keep"])
      return "Invalid parameters"
    end
    
    # Everything looks fine. Carry out the requested choice
    if params[:choice] == "keep"
      # Chose not to trash the card, so a no-op. Just create a history
      game.histories.create!(:event => "#{ply.name} chose not to trash Mining Village.",
                            :css_class => "player#{ply.seat} card_trash")
    else
      # Chose to trash this card
      trash
      
      # Add the cash
      ply.add_cash(2)
      
      # And create a history
      game.histories.create!(:event => "#{ply.name} trashed Mining Village.",
                            :css_class => "player#{ply.seat} card_trash")
    end
    
    return "OK"
  end
end