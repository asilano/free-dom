class BaseGame::Chapel < Card
  costs 2
  action
  card_text "Action (cost: 2) - Trash up to 4 cards from your hand."
  
  def play(parent_act)
    super
    
    # Queue up four actions to Trash a card (the player will be able to get out
    # with the nil_action at any point)
    1.upto(4) do |n|
      parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                              :text => "Trash up to #{n} card#{n != 1 ? 's' : ''} with Chapel")
      parent_act.player = player
      parent_act.game = game
      parent_act.save!
    end
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "trash"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "trash",
                          :text => "Trash",
                          :nil_action => "Trash no more",
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "trash"},
                          :cards => [true] * player.cards.hand.size
                         }]
    end                   
  end                       
  
  def resolve_trash(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
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
    if params.include? :nil_action
      # Player has chosen to "Trash no more". Destroy any remaining Trash
      # actions above here.
      game.histories.create!(:event => "#{ply.name} stopped trashing.",
                            :css_class => "player#{ply.seat} card_trash")
      until parent_act.expected_action != "resolve_#{self.class}#{id}_trash"
        act = parent_act
        parent_act = parent_act.parent
        act.destroy
      end
    else
      # Trash the selected card
      card = ply.cards.hand[params[:card_index].to_i]
      card.trash
      game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand.",
                            :css_class => "player#{ply.seat} card_trash")      
    end
    
    return "OK"
  end
end
