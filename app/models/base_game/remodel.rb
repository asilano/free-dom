class BaseGame::Remodel < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash a card from your hand. " + 
                       "Gain a card costing up to 2 more than the trashed card."
  
  def play(parent_act)   
    super
    
    if player.cards.hand(true).map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve_trash directly
      return resolve_trash(player, {:card_index => 0}, parent_act)
    elsif player.cards.hand.empty?
      # Holding no cards. Just log
      game.histories.create!(:event => "#{player.name} trashed nothing.",
                            :css_class => "player#{player.seat} card_trash")
    else
      # Create a PendingAction to trash a card
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                       :text => "Trash a card with Remodel",
                                       :player => player,
                                       :game => game)
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
                          :nil_action => nil,
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "trash"},
                          :cards => [true] * player.cards.hand.size
                         }]
    when "take"
      valid_piles = game.piles.map do |pile| 
        (pile.cost <= (params[:trashed_cost].to_i + 2)) and not pile.empty?
      end
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :name => "take",
                            :text => "Take",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take",
                                        :trashed_cost => params[:trashed_cost]},
                            :piles => valid_piles
                          }]
    end
  end
  
  def resolve_trash(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if !params.include?(:card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to trash an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"
    
    end
    
    # All checks out. Carry on

    # Trash the selected card, and create a new PendingAction for picking up
    # the remodelled card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost
    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{ply.seat} card_trash")
      
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take;trashed_cost=#{trashed_cost}",
                                     :text => "Take a replacement card with Remodel",
                                     :player => player,
                                     :game => game)
    
    return "OK"
  end
  
  def resolve_take(ply, params, parent_act)
    # We expect to have been passed a :pile_index or :nil_action
    if not params.include? :pile_index and not params.include? :nil_action
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
          (not game.piles[params[:pile_index].to_i].cost <= (params[:trashed_cost].to_i + 2))
      # Asked to take an invalid card (too expensive)
      return "Invalid request - card #{game.piles[params[:pile_index]].card_type} is too expensive"
    elsif (not params.include? :pile_index) and
          (game.piles.map do |pile| 
              (pile.cost <= (params[:trashed_cost].to_i + 2)) and not pile.empty?
           end.any?)
      # Asked to take nothing when there were cards to take
      return "Invalid request - asked to take nothing, but viable replacements exist"    
    end
    
  
    if params.include? :pile_index
      # Process the take. 
      game.histories.create!(:event => "#{ply.name} took " + 
             "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with Remodel.",
                            :css_class => "player#{ply.seat} card_gain")
      ply.queue(parent_act, :gain, :pile => game.piles[params[:pile_index].to_i].id)      
    else
      # Create a history
      game.histories.create!(:event => "#{ply.name} couldn't take a replacement.",
                            :css_class => "player#{ply.seat} card_gain")
    end
    
    return "OK"
  end
end
