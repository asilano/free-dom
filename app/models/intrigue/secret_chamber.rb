class Intrigue::SecretChamber < Card
  costs 2
  action
  reaction
  card_text "Action (Reaction; cost: 2) - Discard any number of cards; +1 Cash " +
                                 "per card discarded. " +
                                 "When another player plays an Attack card, " +
                                 "you may reveal this from your hand. " +
                                 "If you do, draw 2 cards, then put 2 " +
                                 "cards from your hand on top of your deck."
  
  def play(parent_act)
    super
    
    # Just add an action to discard any number of cards
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                     :text => "Discard any number of cards, with Secret Chamber")
    act.player = player
    act.game = game
    act.save!
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "discard"
      controls[:hand] += [{:type => :checkboxes,
                           :action => :resolve,
                           :name => "discard",
                           :choice_text => "Discard",
                           :button_text => "Discard selected",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => [true] * player.cards.hand.size
                          }]
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
  
  def resolve_discard(ply, params, parent_act)
    # The player can choose to discard nothing; if a :discard paramter is
    # present, we expect each entry to be a valid card index.
    if (params.include? :discard and 
        params[:discard].any? {|d| d.to_i < 0 or d.to_i >= ply.cards.hand.size})
      return "Invalid parameters - at least one card index out of range"
    end
   
    # Looks good.
    if not params.include? :discard
      # Nothing to do but create a log
      game.histories.create!(:event => "#{ply.name} discarded no cards to Secret Chamber.",
                            :css_class => "player#{ply.seat} card_discard")
    else
      # Discard each selected card, taking note of its class for logging purposes
      cards_discarded = []
      cards_chosen = params[:discard].map {|ix| ply.cards.hand[ix.to_i]}
      cards_chosen.each do |card|         
        card.discard
        cards_discarded << card.class.readable_name
      end
      
      # Log the discards
      game.histories.create!(:event => "#{ply.name} discarded #{cards_discarded.join(', ')} with Secret Chamber.",
                            :css_class => "player#{ply.seat} card_discard")
      
      # Add the same amount of Cash as cards discarded
      ply.add_cash(cards_discarded.length)
    end
    
    return "OK"
  end
  
  def react(attack_action, parent_act)
    # The Secret Chamber lets you frobble with the top of your deck
    game.histories.create!(:event => "#{player.name} reacted with a Secret Chamber.", 
                          :css_class => "player#{player.seat} play_reaction")
    
    # First, draw two cards
    player.draw_cards(2)
    
    # Now, create a pair of actions to put a card back
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place",
                                     :text => "Place a card on top of deck with Secret Chamber",
                                     :player => player,
                                     :game => game)
    
    act = act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place",
                              :text => "Place a card second-from-top of deck with Secret Chamber",
                              :player => player,
                              :game => game)
                               
    return "OK"
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
