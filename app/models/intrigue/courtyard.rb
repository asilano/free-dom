class Intrigue::Courtyard < Card
  costs 2
  action
  card_text "Action (cost: 2) - Draw 3 cards. " +
                       "Put a card from your hand on top of your deck."                       
  
  def play(parent_act)   
    super
    
    # First, draw three cards
    player.draw_cards(3)
    
    # Now create a PendingAction to place a card
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place",
                                     :text => "Place a card on deck with Courtyard")
    act.player = player
    act.game = game
    act.save!
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "place"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "place",
                          :text => "Choose",
                          :nil_action => 
                              (player.cards.hand.empty? ? "Place nothing" : nil),
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "place"},
                          :cards => [true] * player.cards.hand.size
                         }]
    end
  end
  
  def resolve_place(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to place an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"  
    end
    
    # All checks out. Carry on
    if params.include? :nil_action
      game.histories.create!(:event => "#{ply.name} placed nothing on his or her deck.",
                            :css_class => "player#{ply.seat}")
    else
      # Place the selected card on the player's deck
      card = ply.cards.hand[params[:card_index].to_i]
      card.location = "deck"      
      card.position = -1
      card.save!
      ply.renum(:deck)
      game.histories.create!(:event => "#{ply.name} put a [#{ply.id}?#{card.class.readable_name}|card] on top of his or her deck.", 
                            :css_class => "player#{ply.seat}")
    end
    
    return "OK"
  end
end