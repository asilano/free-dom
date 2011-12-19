class BaseGame::Bureaucrat < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - Gain a Silver card; put it on top of your deck. " +
                               "Each other player reveals a Victory card from " +
                               "his or her hand and puts it on top of their " +
                               "deck, or reveals a hand with no Victory cards."

  def play(parent_act)
    super
    
    # First, acquire a Silver to top of deck.
    silver_pile = game.piles.find_by_card_type("BasicCards::Silver")
    player.queue(parent_act, :gain, :pile => silver_pile.id, :location => "deck")

    game.histories.create!(:event => "#{player.name} gained a Silver to top of their deck.", 
                          :css_class => "player#{player.seat} card_gain")
    
    # Now, attack
    attack(parent_act)
  end
  
  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)
    
    case substep
    when "victory"
      # Ask the attack target for a Victory card, or to reveal a hand devoid of
      # all such.
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :name => "victory",
                           :text => "Place",
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "victory"},
                           :cards => player.cards.hand.map {|c| c.is_victory? }
                          }]
    end                          
  end
  
  def attackeffect(params)
    # Effect of the attack succeeding - that is, ask the target to put a Victory
    # card on top of their deck.
    target = Player.find(params[:target])
    # source = Player.find(params[:source])
    parent_act = params[:parent_act]

    # Handle autocratting
    target_victories = target.cards.hand(true).select {|c| c.is_victory?}
    
    if (target.settings.autocrat_victory &&
        target_victories.map {|c| c.class}.uniq.length == 1)
      # Target is autocratting victories, and holding exactly one type of
      # victory card. Find the index of that card, and call resolve_victory
      vic = target_victories[0]
      index = target.cards.hand.index(vic)
      return resolve_victory(target, {:card_index => index}, parent_act)
    elsif target_victories.empty?
      # Target is holding no victories. Call resolve_victory for the nil_action
      return resolve_victory(target, {:nil_action => true}, parent_act)
    else
      # Autocrat doesn't apply. Create the pending action to request the Victory 
      # card
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_victory",
                                 :text => "Place a Victory card onto deck",
                                 :player => target,
                                 :game => game)
    end    

    return "OK"
  end
  
  def resolve_victory(ply, params, parent_act)
    # This is at the attack target either putting a card back on their deck,
    # or revealing a hand devoid of victory cards. We should expect a 
    # :card_index or a :nil_action parameter
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to replace an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"
    elsif params.include? :card_index and 
          not ply.cards.hand[params[:card_index].to_i].is_victory?
      # Asked to replace an invalid card (not a Victory card)
      return "Invalid request - card index #{params[:card_index]} is not a Victory card"    
    elsif params.include? :nil_action and ply.cards.hand.any? {|c| c.is_victory?}
      # Asked to reveal hand when hand contains a Victory
      return "Invalid request - must place a Victory card on deck"
    end
    
    # All looks good - process the request
    if params.include? :nil_action
      # :nil_action specified. "Reveal" the player's hand. Since no-one needs to
      # act on the revealed cards, just add a history entry detailing them.
      game.histories.create!(:event => "#{ply.name} revealed their hand to the Bureaucrat:", 
                            :css_class => "player#{ply.seat} card_reveal")
      game.histories.create!(:event => "#{ply.name} revealed #{ply.cards.hand.map {|c| c.class.readable_name}.join(', ')}.", 
                            :css_class => "player#{ply.seat} card_reveal")
    else
      # :card_index specified. Place the specified card on top of the player's
      # deck, and "reveal" it by creating a history.
      card = ply.cards.hand[params[:card_index].to_i]
      card.location = "deck"      
      card.position = -1
      card.save!
      ply.renum(:deck)
      game.histories.create!(:event => "#{ply.name} put a #{card.class.readable_name} on top of their deck.", 
                            :css_class => "player#{ply.seat}")
    end
    
    return "OK"
  end
end
