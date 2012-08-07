class BaseGame::ThroneRoom < Card
  costs 4
  action
  card_text "Action (cost: 4) - Choose an Action card in hand. Play it twice."
  
  serialize :state

  # Throne room is a touch complicated. We will need to:
  # * On Play, ask the player to choose an Action card in hand
  # * On resolution of that choice, create two Game actions, one the child of
  #   the other; both to Resolve half of Throne Room, and carrying the chosen
  #   card's ID as a param
  # * On resolution of the Game actions, look up the specified card, and Play it
  def play(parent_act)
    super

    if player.cards.hand(true).select {|c| c.is_action?}.map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve directly
      ix = player.cards.hand.index {|c| c.is_action?}      
      return resolve(player, {:card_index => ix}, parent_act)
    elsif !(player.cards.hand.any? {|c| c.is_action?})
      # Holding no Actions. Just log
      game.histories.create!(:event => "#{player.name} chose no action to double.",
                            :css_class => "player#{player.seat}")
    else
      # Create a PendingAction to choose a card
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}",
                                       :text => "Choose a card to play with Throne Room",
                                       :player => player,
                                       :game => game)
    end
        
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    # This is the Throne Room's controller choosing an Action card
    controls[:hand] += [{:type => :button,
                         :action => :resolve,
                         :name => "choose",
                         :text => "Choose",
                         :nil_action => nil,
                         :params => {:card => "#{self.class}#{id}"},
                         :cards => player.cards.hand.map do |card|
                           card.is_action?
                         end
                        }] 
  end
  
  def resolve(ply, params, parent_act)
    # Player has made a choice of what card to play, twice.
    # We expect to have been passed a :card_index
    if !params.include? :card_index
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if (params[:card_index].to_i < 0 ||
        params[:card_index].to_i > ply.cards.hand.length - 1)
      # Asked to play an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"
    elsif !ply.cards.hand[params[:card_index].to_i].is_action?
      # Asked to play an invalid card (not an reaction)
      return "Invalid request - card index #{params[:card_index]} is not an action"
    end
    
    # Now process the action chosen
    
    # Player chose a card. Create two Game-level actions under the parent
    # to play that card.
    chosen = ply.cards.hand[params[:card_index].to_i]      
    game.histories.create!(:event => "#{ply.name} chose #{chosen.class.readable_name} to double.",
                          :css_class => "player#{ply.seat}")
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}" +
                                                         "_playaction;" + 
                                                         "type=#{chosen[:type]};id=#{chosen.id}",
                                                         :game => game)      
    act.children.create!(:expected_action => "resolve_#{self.class}#{id}" +
                                                  "_playaction;" + 
                                                  "type=#{chosen[:type]};id=#{chosen.id}",
                                                  :game => game)      
                                                  
    if chosen.is_duration?
      # Chosen card is a duration. That means Throne Room should also endure
      # Because you can TR a TR, and choose two durations, we must make state
      # an array, and append to it.
      self.location = "enduring"
      self.state_will_change!
      self.state ||= []
      self.state << "#{chosen.class};#{chosen.id}"
    end
    
    save!
    
    return "OK"
  end
  
  def playaction(params)
    # This is one of the two Game-level actions created to play the chosen card
    # twice. First, pick up the card.
    card_class = to_class(params[:type])
    card_id = params[:id].to_i
    card = card_class.find(card_id)
    parent_act = params[:parent_act]
    
    # By far the simplest thing to do is to call the play method of the card.
    # However, the card needs to belong to the player, and it may have been trashed
    # during the first play. Some cards care whether they're in trash (for instance
    # Mining Village), so leave it where it is but set the player.
    card.player = player
    return card.play(parent_act)
  end
  
  def end_duration(parent_act)
    super
    
    # Throne Room coming off duration? That must mean it's attached to a duration
    raise "Throne Room #{id} enduring without any state!" if state.empty?
    state_will_change!
    state_item = state.pop
    save!

    /([[:alpha:]]+::[[:alpha:]]+);([[:digit:]]+)/.match(state_item)
    card_type = $1
    card_id = $2
    
    card = card_type.constantize.find(card_id)
    
    if !card.is_duration?
      raise "Throne Room #{id} enduring without a duration attached!"
    end
    
    # Add in a game-level action to re-end the duration of the attached card
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}" +
                                                   "_attachedduration;" + 
                                                   "type=#{card_type};id=#{card_id}",
                                                   :game => game)

    return "OK"
  end
  
  def attachedduration(params)
    # This is the Game-level action created to get the end-of-duration effects
    # of the chosen card again.
    card_class = to_class(params[:type])
    card_id = params[:id].to_i
    card = card_class.find(card_id)
    parent_act = params[:parent_act]
    
    # By far the simplest thing to do is to call the end_duration method of the card.
    # That requires the card to be "enduring". Nothing else should need to be changed
    card.location = "enduring"
    return card.end_duration(parent_act)
  end
  
end
