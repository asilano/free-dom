# 2  Haven  Seaside  Action - Duration  $2  +1 Card, +1 Action, Set aside a card from your hand face down. At the start of your next turn, put it into your hand.

class Seaside::Haven < Card
  costs 2
  action :duration => true
  card_text "Action (Duration; cost: 2) - Draw 1 Card, +1 Action. Set aside a card from your hand face down. At the start of your next turn, put it into your hand."
  
  serialize :state
  
  def play(parent_act)
    super
    
    player.draw_cards(1)
    parent_act = player.add_actions(1, parent_act)
    
    if player.cards.hand(true).map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve directly
      return resolve_setaside(player, {:card_index => 0}, parent_act)
    elsif player.cards.hand.empty?
      # Holding no cards. Just log
      game.histories.create!(:event => "#{player.name} set nothing aside, as their hand was empty.",
                            :css_class => "player#{player.seat}")
      self.state = []
      save!
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
                          :nil_action => (player.cards.hand.empty? ? "Set nothing aside" : nil),
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "setaside"},
                          :cards => [true] * player.cards.hand.size
                         }]
    end
  end
  
  def resolve_setaside(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to set aside an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"
    elsif params.include? :nil_action and not ply.cards.hand.empty?
      # Asked to set nothing aside when the hand has cards in
      return "Invalid request - must set a card aside"
    end
    
    # All checks out. Carry on
    if params.include? :nil_action
      game.histories.create!(:event => "#{ply.name} set nothing aside, as their hand was empty.",
                            :css_class => "player#{ply.seat}")
    else
      # Set the selected card aside - that is, move it to the "haven" location
      card = ply.cards.hand[params[:card_index].to_i]
      card.location = "haven"
      card.save!
      
      # Note on this card's state the set-aside card. Because of the existence of Throne Room,
      # we keep an Array of set-asides, and must cope with it being already-populated
      state_will_change!
      self.state ||= []
      self.state << card.id
      save!
      
      game.histories.create!(:event => "#{ply.name} set [#{ply.id}?#{card.readable_name}|a card] aside from their hand.",
                            :css_class => "player#{ply.seat}")
      
      
    end
    
    return "OK"
  end
  
  def end_duration(parent_act)
    super
    
    # Return each card set aside with Haven to the hand    
    if !self.state.empty?
      state_will_change!
      ix = self.state.pop
      card = Card.find(ix)
      card.location = "hand"
      card.save!
      save!
      
      game.histories.create!(:event => "#{player.name} returned [#{player.id}?#{card.readable_name}|a card] to their hand from the Haven.",
                            :css_class => "player#{player.seat}")
    end                 
    
    return "OK"
  end
  
end

