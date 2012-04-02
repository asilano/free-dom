class Intrigue::Pawn < Card
  costs 2
  action
  card_text "Action (cost: 2) - Choose two: Draw 1 card; +1 Action; +1 Buy; +1 Cash."                 
  
  def play(parent_act)   
    super
    
    # Just create a PendingAction to choose the things to do
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choice",
                                     :text => "Choose two, with Pawn")
    act.player = player
    act.game = game
    act.save!
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "choice"
      controls[:player] += [{:type => :checkboxes,
                             :action => :resolve,
                             :name => "choice",
                             :label => "Choose Two",
                             :choices => ["Draw 1", "+1 Action", "+1 Buy", "+1 Cash"],
                             :button_text => ["Submit Choice"],
                             :params => {:card => "#{self.class}#{id}", :substep => 'choice'}
                            }]
    end                            
  end
  
  def resolve_choice(ply, params, parent_act)
    # We expect exactly two choices. Interestingly, if we don't have that, the
    # likely cause is user error, in which case we should be taking steps to
    # keep the buttons etc. available. So we'll succeed the action, but add an
    # identical action to ask again, and update the flash.
    if not params.include? :choice or params[:choice].length != 2      
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choice",
                                     :text => "Choose two, with Pawn")
      act.player = player
      act.game = game
      act.save!
      return "OK You must select exactly two options"
    end
    
    # Looks good.
    game.histories.create!(:event => "#{ply.name} chose #{params[:choice].map{|c| ["Draw", "Action", "Buy", "Cash"][c.to_i]}.join(' and ')} with Pawn.", 
                          :css_class => "player#{ply.seat}")
    params[:choice].each do |choice|
      case choice.to_i
      when 0
        # Draw a card        
        ply.draw_cards(1)
      when 1
        # Add an action
        ply.add_actions(1, parent_act)
      when 2
        # Add a buy
        ply.add_buys(1, parent_act)
      when 3
        # Add a cash
        player.add_cash(1)
      else
        return "Unexpected choice #{choice}"
      end
    end
    
    return "OK"
  end
end