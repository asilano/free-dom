class Intrigue::Masquerade < Card
  costs 3
  action
  card_text "Action (cost: 3) - Draw 2 cards. Each player passes a card from his or " +
                       "her hand to the left at once. Then you may trash a " +
                       "card from your hand. (This is not an Attack)"
  
  def play(parent_act)
    super
    
    # First, draw 2 cards.
    player.draw_cards(2)
    
    # Masquerade is a little tricky. We need an action to optionally Trash,
    # which can't trigger until each player has chosen and passed a card.
    #
    # Passing a card involves choosing a card to pass left, and only then
    # receiving a card from the right (if available). This means that each
    # player's "pass left" action blocks two others (that player's "receive from
    # right", and the left player's "receive from right"). That is:
    #
    #    Alan Trash<-+-Alan Receive<----------------+
    #                |              \               |
    #                |               >--Alan Pass   |
    #                |              /               |
    #                +--Bob Receive<                +---Carl Pass
    #                |              \               |
    #                |               >--Bob Pass    |
    #                |              /               |
    #                +-Carl Receive<----------------+
    #
    # ... but acts_as_tree can't handle that. So instead, we'll create fake
    # duplicate actions for each player, which provide no controls, and get 
    # deleted along with the original - like so: 
    #
    #    Alan Trash<-+-Alan Receive<----Carl Pass
    #                |              \---Alan Dup   
    #                |                              
    #                |              /---Alan Pass   
    #                +--Bob Receive<                
    #                |              \---Bob Dup    
    #                |                              
    #                |              /---Bob Pass    
    #                +-Carl Receive<----Carl Dup
    
    # First, create the Trash action
    trash_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                           :text => "Optionally trash a card with Masquerarde",
                                           :player => player,
                                           :game => game)
    trash_act.save!
    
    # Now, create the game-scope actions to receive cards, and the dummy player-
    # scope actions blocking them. We'll need the receive actions and the IDs of
    # the dummy actions in a bit.
    rcv_acts = []
    dup_ids = []
    game.players.each do |ply|
      rcv_act = trash_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_receive;rcvr=#{ply.id}",
                                          :game => game)
      rcv_act.save!
      rcv_acts << rcv_act
      dup_act = rcv_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_dummy",
                                        :text => "",
                                        :player => ply,
                                        :game => game)
      dup_act.save!
      dup_ids << dup_act.id
    end
    
    # Finally, create the actual pass actions, blocking the receive action of
    # the player to the left (that is, the next player).
    game.players.each_with_index do |ply, ix|
      next_ix = (ix + 1) % game.players.length
      pass_act = rcv_acts[next_ix].children.create!(:expected_action => "resolve_#{self.class}#{id}_pass;destroy=#{dup_ids[ix]}",
                                                   :text => "Pass a card to #{game.players[next_ix].name}",
                                                   :player => ply,
                                                   :game => game)
      pass_act.save!                                             
    end  
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "pass"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "pass",
                          :text => "Pass to #{player.next_player.name}",
                          :nil_action => 
                              (player.cards.hand.empty? ? "Pass nothing" : nil),
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "pass",
                                      :destroy => params[:destroy]},
                          :cards => [true] * player.cards.hand.size
                         }]
    when "trash"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "trash",
                          :text => "Trash",
                          :nil_action => "Trash nothing",
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "trash"},
                          :cards => [true] * player.cards.hand.size
                         }]
    end                     
  end
  
  def resolve_pass(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to pass an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range" 
    elsif ((params.include? :nil_action) and
           not ply.cards.hand.empty?)
      # Tried to pass nothing when there were cards in hand
      return "Invalid request - must pass a card"     
    end
    
    # All checks out. Carry on
    if params.include? :nil_action
      # Player has chosen to pass nothing. Just create a history
      game.histories.create!(:event => "#{ply.name} passed no card - hand empty.",
                            :css_class => "player#{ply.seat}")      
    else
      # Pass the selected card - give it to the next player, in "masq_limbo"
      card = ply.cards.hand[params[:card_index].to_i]
      card.player = ply.next_player
      card.location = "masq_limbo"
      card.revealed = false
      card.save!
      game.histories.create!(:event => "#{ply.name} passed a " + 
                               "[#{ply.id}?#{card.class.readable_name}|card] " + 
                               "to #{ply.next_player.name}.",
                            :css_class => "player#{ply.seat}")      
    end
    
    # In either case, we now need to destroy the dummy pending action indicated
    # by the "destroy" parameter - which must exist
    dummy_act = PendingAction.find(params[:destroy])
    raise "unexpected dummy action" unless dummy_act.expected_action == "resolve_#{self.class}#{id}_dummy"
    dummy_act.destroy
    
    return "OK"
  end
  
  def receive(params)
    # Game-handled action to cause the player to receive the card passed to them
    player = Player.find(params[:rcvr])
    cards = player.cards.in_location('masq_limbo')
    raise "Unexpected multiple cards to receive" unless cards.length == 1
    card = cards[0]
    
    card.location = "hand"
    card.position = player.cards.hand.size + 1
    card.save!
    game.histories.create!(:event => "#{player.name} received a " + 
                            "[#{player.id}?#{card.class.readable_name}|card] " + 
                            "from #{player.prev_player.name}.",
                          :css_class => "player#{player.seat}")
                                
    return "OK"                            
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
      # Player has chosen to "Trash nothing". Just create a history.
      game.histories.create!(:event => "#{ply.name} trashed nothing.",
                            :css_class => "player#{ply.seat} card_trash")      
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