class Intrigue::Nobles < Card
  costs 6
  victory :points => 2
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..6
                              12
                            end}
  action
  card_text "Action/Victory (cost: 6) - Choose one: Draw 3 cards, " + 
            "or +2 Actions. / 2 points"
            
  def play(parent_act)
    super
    
    # Ask which mode the player wants.
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                               :text => "Choose Nobles' effect",
                               :player => player,
                               :game => game)
                               
    return "OK"                           
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "choose"
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :name => "choose",
                             :label => "#{readable_name}:",                             
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "choose"},
                             :options => [{:text => "Draw three",            
                                           :choice => "draw"},
                                          {:text => "Two actions",                               
                                           :choice => "actions"}]
                            }]
    end
  end                          
  
  def resolve_choose(ply, params, parent_act)
    # We expect to have a :choice parameter, either of "draw" or "actions"
    if (not params.include? :choice) or
       (not params[:choice].in? ["draw", "actions"])
      return "Invalid parameters"
    end
    
    # Everything looks fine. Carry out the requested choice
    case params[:choice]
    when "draw"
      game.histories.create!(:event => "#{ply.name} chose to draw cards from the Nobles.", 
                            :css_class => "player#{ply.seat}")
      ply.draw_cards(3)
    when "actions"
      game.histories.create!(:event => "#{ply.name} chose to gain actions from the Nobles.", 
                            :css_class => "player#{ply.seat}")
      ply.add_actions(2, parent_act)
    end
    
    return "OK"
  end
  
end
