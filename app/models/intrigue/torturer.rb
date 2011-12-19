class Intrigue::Torturer < Card
  costs 5
  action :attack => true, 
         :order_relevant => lambda {
           curses_pile = game.piles.find_by_card_type("BasicCards::Curse")
           curses_pile.cards.length < game.players.length - 1}
  card_text "Action (Attack; cost: 5) - Draw 3 cards. Each other player chooses: " +
            "he discards 2 cards, or he gains a Curse card into his hand."
            
  def play(parent_act)
    super
    
    player.draw_cards(3)
    attack(parent_act)
    return "OK"
  end
          
  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)
    
    case substep
    when "choose"
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :name => "choose",
                             :label => "#{readable_name} effect:",                             
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "choose"},
                             :options => [{:text => "Discard 2 cards",            
                                           :choice => "discard"},
                                          {:text => "Gain a Curse",
                                           :choice => "curse"}]
                            }]
    when "discard"
      # This is the target choosing one card to discard
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :name => "discard",
                           :text => "Discard",
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => [true] * player.cards.hand.size
                          }]                        
    end  
  end
    
  def attackeffect(params)
    # Effect of the attack succeeding - that is, ask the target to choose to 
    # discard, or gain a Curse.
    target = Player.find(params[:target])
    parent_act = params[:parent_act]
    
    if target.settings.autotorture.curse
      # Target has chosen to always take a curse. How odd. Ah well, call resolve_choose directly
      return resolve_choose(target, {:choice => 'curse'}, parent_act)
    else
      # Add the choice action
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                 :text => "Choose 'Discard' or 'Gain a Curse'",
                                 :player => target,
                                 :game => game)
    end
    
    return "OK"                           
  end
            
  def resolve_choose(ply, params, parent_act)
    # We expect to have a :choice parameter, one of "discard" and "curse"
    if (not params.include? :choice) or
       (not params[:choice].in? ["discard", "curse"])
      return "Invalid parameters"
    end
    
    # Everything looks fine. Carry out the requested choice
    if params[:choice] == "discard"
      if ply.cards.hand(true).length >= 1
        # Create a pair of actions to request the discard, similar to Militia.
        # The choice has held up other players' attack effects, but the discard
        # doesn't need to. So step back until we reach an action that isn't our
        # doattack.
        until parent_act.expected_action !~ /^resolve_#{self.class}#{id}_doattack/ do
          parent_act = parent_act.parent
        end        
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                                :text => "Discard a card",
                                                :player => ply,
                                                :game => game)
        
        if ply.cards.hand(true).length >= 2
          # Player has at least two cards, so should have the second action created
          parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                     :text => "Discard 2 cards",
                                     :player => ply,
                                     :game => game)  
        end
      else
        game.histories.create!(:event => "#{ply.name} couldn't discard - no cards in hand.", 
                              :css_class => "player#{ply.seat} card_discard")
      end
    else
      # Gain a Curse, exactly as for Witch except that the card goes to hand.
      curses_pile = game.piles.find_by_card_type("BasicCards::Curse")
      if not curses_pile.empty?
        game.histories.create!(:event => "#{ply.name} gained a Curse.",
                              :css_class => "player#{ply.seat} card_gain")

        ply.queue(parent_act, :gain, :pile => curses_pile.id, :location => "hand") 
      else
        game.histories.create!(:event => "#{ply.name} couldn't gain a Curse - none left.", 
                              :css_class => "player#{ply.seat}")
      end
    end
    
    return "OK"
  end
            
  def resolve_discard(ply, params, parent_act)
    # This is processing the target's request to discard a card
    # We expect to have been passed a :card_index
    if not params.include? :card_index
      return "Invalid parameters"
    end
    
    # Processing is surprisingly similar to a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to discard an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"    
    end
    
    # All checks out. Discard the selected card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.discard    
    game.histories.create!(:event => "#{ply.name} discarded #{card.class.readable_name}.",
                          :css_class => "player#{ply.seat} card_discard")
    
    return "OK"
  end          
            
end