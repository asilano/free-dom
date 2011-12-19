class BaseGame::Cellar < Card
  costs 2
  action
  card_text "Action (cost: 2) - +1 Action. Discard any number of cards. Draw 1 card " +
                       "per card discarded."
  
  def play(parent_act)
    super
    
    # Grant the player another action, and take note of it
    parent_act = player.add_actions(1, parent_act)
    
    # Now add an action to discard any number of cards
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                     :text => "Discard any number of cards, with Cellar")
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
      game.histories.create!(:event => "#{ply.name} discarded no cards to Cellar.",
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
      game.histories.create!(:event => "#{ply.name} discarded #{cards_discarded.join(', ')} with Cellar.",
                            :css_class => "player#{ply.seat} card_discard")
      
      # Draw the same number of replacement cards
      ply.draw_cards(cards_discarded.length)
    end
    
    return "OK"
  end
end
