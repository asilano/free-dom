# 13  Island  Seaside  Action - Victory  $4  Set aside this and another card from your hand. Return them to your deck at the end of the game. 2 VP

class Seaside::Island < Card
  costs 4
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..6
                              12
                            end}
  action
  victory :points => 2
  card_text "Action/Victory (cost: 4) - Set aside this and another card from your hand. Return them to your deck at the end of the game. / 2 points."
  
  def play(parent_act)
    super
    
    if player.cards.hand(true).map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve directly
      return resolve(player, {:card_index => 0}, parent_act)
    elsif player.cards.hand.empty?
      # Holding no cards. Just log
      game.histories.create!(:event => "#{player.name} only set #{self}, as their hand was empty.",
                            :css_class => "player#{player.seat}")
    else
      # Queue up an action for setting a card aside
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_setaside",
                                 :text => "Set a card aside with #{readable_name}.",
                                 :player => player,
                                 :game => game)
    end
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "setaside"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "setaside",
                          :text => "Set Aside",
                          :nil_action => nil,
                          :params => {:card => "#{self.class}#{id}"},
                          :cards => [true] * player.cards.hand.size
                         }]
    end
  end
  
  def resolve(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to set aside an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end
    
    # All checks out. Carry on
    # First set the Island itself aside
    self.location = "island"
    self.save!
    
    # Set the selected card aside - that is, move it to the "island" location
    card = ply.cards.hand[params[:card_index].to_i]
    card.location = "island"
    card.save!

    game.histories.create!(:event => "#{ply.name} set #{readable_name} and #{card.readable_name} aside from their hand.",
                          :css_class => "player#{ply.seat}")          
    
    return "OK"
  end
    
  # Note that we don't need to do anything at game end, since the scoring routines count all cards
  # owned by the player, regardless of location.        
        
end

