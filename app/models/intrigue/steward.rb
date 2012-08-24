class Intrigue::Steward < Card
  costs 3
  action
  card_text "Action (cost: 3) - Choose one: Draw 2 cards; or +2 cash; or trash 2 " +
                       "cards from your hand."
  
  def play(parent_act)
    super
    
    # Just create a pending action to choose which effect to have
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                               :text => "Choose Steward's effect",
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
                             :options => [{:text => "Draw two",
                                           :choice => "draw"},
                                          {:text => "Two cash",
                                           :choice => "cash"},
                                          {:text => "Trash two",
                                           :choice => "trash"}]
                            }]
    when "trash"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "trash",
                          :text => "Trash",                          
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "trash"},
                          :cards => [true] * player.cards.hand.size
                         }]
    end  
  end
  
  def resolve_choose(ply, params, parent_act)
    # We expect to have a :choice parameter, one of "draw", "cash", "trash"
    if (not params.include? :choice) or
       (not params[:choice].in? ["draw", "cash", "trash"])
      return "Invalid parameters"
    end
    
    # Everything looks fine. Carry out the requested choice
    case params[:choice]
    when "draw"
      game.histories.create!(:event => "#{ply.name} chose to draw cards from the Steward.", 
                            :css_class => "player#{ply.seat}")
      ply.draw_cards(2)
    when "cash"
      game.histories.create!(:event => "#{ply.name} chose to gain cash from the Steward.", 
                            :css_class => "player#{ply.seat}")
      ply.add_cash(2)
    when "trash"
      # Trashing options doesn't work exactly like Chapel - you must trash two
      # cards if able. Mostly, this will be handled by determine_controls, but
      # we can make life easier here.
      game.histories.create!(:event => "#{ply.name} chose to trash cards with the Steward.", 
                            :css_class => "player#{ply.seat}")
      
      if ply.cards.hand.length >= 1
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                                :text => "Trash a card with Steward",
                                                :player => ply,
                                                :game => game)      
        parent_act.save!
        
        if ply.cards.hand.length >= 2
          parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                                  :text => "Trash 2 cards with Steward",
                                                  :player => ply,
                                                  :game => game)      
          parent_act.save!
        end
      else
        # No cards in hand; just log.
        game.histories.create!(:event => "#{ply.name} had no cards in hand to trash.",
                               :css_class => "player#{ply.seat}")
      end
    end
    
    return "OK"
  end
  
  def resolve_trash(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if (not params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to trash an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"    
    end
    
    # All checks out. Carry on    
    # Trash the selected card
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash
    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand.",
                          :css_class => "player#{ply.seat} card_trash")      
    
    return "OK"
  end
end
