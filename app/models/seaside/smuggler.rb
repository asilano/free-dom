# 9  Smugglers  Seaside  Action  $3  Gain a copy of a card costing up to 6 Coins that the player to your right gained on his last turn.

class Seaside::Smuggler < Card
  costs 3
  action
  card_text "Action (cost: 3) - Gain a copy of a card costing up to 6 Cash that the player to your right gained on his last turn."
  
  def play(parent_act)
    super
    
    # TODO: Should be select?
    valid_piles = game.piles.map do |pile| 
      (pile.cost <= 6 && 
       player.prev_player.state.gained_last_turn.include?(pile.card_class.to_s) &&
       !pile.empty?)
    end
    
    if valid_piles.empty?
      # Previous player gained nothing viable. Just log
      game.histories.create!(:event => "#{player.name} couldn't Smuggle anything.",
                            :css_class => "player#{player.seat}")
    elsif valid_piles.length == 1
      # Only one viable choice. Take it automatically
      game.histories.create!(:event => "#{player.name} took #{valid_piles[0].card_class.readable_name} with Smuggler.",
                            :css_class => "player#{player.seat} card_gain")
      
      player.gain(parent_act, valid_piles[0].id)
    else
      # An actual choice exists. Ask the player
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take",
                                :text => "Take a card with Smuggler",
                                 :player => player,
                                 :game => game)
    end
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep    
    when "take"
      valid_piles = game.piles.map do |pile| 
        (pile.cost <= 6 && 
         player.prev_player.state.gained_last_turn.include?(pile.card_class.to_s) &&
         !pile.empty?)
      end
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :name => "take",
                            :text => "Take",
                            :nil_action => (valid_piles.any? ? nil : "Take nothing"),
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take"},
                            :piles => valid_piles
                          }]
    end
  end
  
  def resolve_take(ply, params, parent_act)
    # We expect to have been passed a :pile_index or :nil_action
    if not params.include? :pile_index and not params.include? :nil_action
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a buy; code shamelessly yoinked from
    # Player.buy.
    pile_index = params[:pile_index] && params[:pile_index].to_i
    if (pile_index && 
        (pile_index < 0 ||
         pile_index > game.piles.length - 1))            
      # Asked to take an invalid card (out of range)        
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif (pile_index && 
           !(game.piles[pile_index].cost <= 6))
      # Asked to take an invalid card (too expensive)
      return "Invalid request - card #{game.piles[pile_index].card_type} is too expensive"
    elsif (pile_index && 
           !ply.prev_player.state.gained_last_turn.include?(game.piles[pile_index].card_class.to_s))
      # Asked to take an invalid card (not taken by last player
      return "Invalid request - card #{game.piles[pile_index]} wasn't gained by the last player"
    elsif (!pile_index and
           (game.piles.any? do |pile| 
              (pile.cost <= 6 && 
               player.prev_player.state.gained_last_turn.include?(pile.card_class.to_s) &&
               !pile.empty?)
           end))
      # Asked to take nothing when there were cards to take
      return "Invalid request - asked to take nothing, but viable piles exist"
    end
    
    if pile_index
      # Process the take. 
      game.histories.create!(:event => "#{ply.name} took #{game.piles[pile_index].card_class.readable_name} with Smuggler.",
                            :css_class => "player#{ply.seat} card_gain")
      
      ply.gain(parent_act, game.piles[params[:pile_index].to_i].id)     
    else
      
    end
    
    return "OK"
  end
  
end

