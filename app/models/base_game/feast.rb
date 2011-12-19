class BaseGame::Feast < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash this card. Gain a card costing up to 5."
  
  def play(parent_act)
    super
    
    # First create a PendingAction to take a replacement.
    # We do this first, since we still have a Player here
    #
    # Note that Feast doesn't care whether the trash succeeded when gaining
    # the replacement.
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take",
                               :text => "Take a card with Feast",
                               :player => player,
                               :game => game)
    
    # Now move this card to Trash
    trash      
    
    return "OK"    
  end
  
  def determine_controls(player, controls, substep, params)
    case substep    
    when "take"
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :name => "take",
                            :text => "Take",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take"},
                            :piles => game.piles.map do |pile|
                              pile.cost <= 5
                            end
                          }]
    end
  end
  
  def resolve_take(ply, params, parent_act)
    # We expect to have been passed a :pile_index
    if not params.include? :pile_index
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a buy; code shamelessly yoinked from
    # Player.buy.
    if ((params.include? :pile_index) and 
           (params[:pile_index].to_i < 0 or
            params[:pile_index].to_i > game.piles.length - 1))            
      # Asked to take an invalid card (out of range)        
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif (params.include? :pile_index) and 
          (not game.piles[params[:pile_index].to_i].cost <= 5)
      # Asked to take an invalid card (too expensive)
      return "Invalid request - card #{game.piles[params[:pile_index]].card_type} is too expensive"
    end
    
  
    # Process the take.
    game.histories.create!(:event => "#{ply.name} took " + 
           "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with Feast.",
                          :css_class => "player#{ply.seat} card_gain")

    ply.queue(parent_act, :gain, :pile => game.piles[params[:pile_index].to_i].id)
    
    return "OK"
  end
end
