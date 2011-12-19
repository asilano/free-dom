# 6	Ambassador	Seaside	Action - Attack	$3	Reveal a card from your hand. Return up to 2 copies of it from your hand to the Supply. Then each other player gains a copy of it.

class Seaside::Ambassador < Card
  costs 3
  action :attack => true, 
         :order_relevant => lambda { |params|
           pile = game.piles.find_by_card_type(params[:chosen])
           pile.cards.length < game.players.length - 1}

  card_text "Action (Attack; cost: 3) - Reveal a card from your hand. Return up to 2 copies of it from your hand to the Supply. Then each other player gains a copy of it."

  # Reveal a card from hand (throw the card class (name?) on the end of the new action
  # Select as many of thse as you like (the card class is in params, pass it BACK in params into the execute method)
  # Those are returned to the supply
  # And every other player then takes one (and we don't NEED another action for this, just touch the other players discard directly, like tribute does)

  def play(parent_act)   
    super    
    
    if player.cards.hand(true).map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve_reveal directly
      return resolve_reveal(player, {:card_index => 0}, parent_act)
    elsif player.cards.hand.empty?
      # Holding no cards. Just log
      game.histories.create!(:event => "#{player.name} revealed nothing, as their hand was empty.",
                            :css_class => "player#{player.seat} card_trash")
    else
      # Create a PendingAction to reveal a card
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_reveal",
                                 :text => "Reveal a card with Ambassador",
                                 :player => player,
                                 :game => game)
    end
    
    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)
    case substep
    when "reveal"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "reveal",
                          :text => "Reveal",
                          :nil_action => nil,
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "reveal"},
                          :cards => [true] * player.cards.hand.size
                         }]
    when "returncard"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "returncard",
                          :text => "Return",
                          :nil_action => "Return no more",
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "returncard",
                                      :chosen => params[:chosen],
                                      :remain => params[:remain]
                                     },
                          :cards => player.cards.hand.map do |card|
                                                             card.class.name == params[:chosen]
                                                          end
                         }]
    end
  end

  def resolve_reveal(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if !params.include? :card_index
      return "Invalid parameters"
      end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to reveal an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end
       
    card = ply.cards.hand[params[:card_index].to_i]
    game.histories.create!(:event => "#{ply.name} revealed a #{card.class.readable_name}.",
                          :css_class => "player#{ply.seat} card_reveal")
    # Queue up actions to return a card (the player will be able to get out with the nil_action at any point)
    parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_returncard;chosen=#{card.class.name};remain=2",
                                            :text => "Return up to 2 cards with Ambassador",
                                            :player => player,
                                            :game => game)
    
    return "OK"
    
  end

  def resolve_returncard(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to return an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"    
    end

    if params.include? :card_index
      # Return this card to the supply
      card = ply.cards.hand[params[:card_index].to_i]
      
      if (card.class.name != params[:chosen])
        return "Invalid request - returning a #{card.readable_name} when a #{params[:chosen]} was revealed"
      end
      
      if card.class.starting_size(4) == :unlimited
        # Card is unlimited, so we don't /really/ want to return it. Just destroy it.
        card.destroy
      else
        pile = game.piles.find_by_card_type(params[:chosen])
        card.pile_id = pile.id
        card.location = 'pile'
        card.position = 0
        card.revealed = false
        card.player = nil
        card.save!
      end
      
      game.histories.create!(:event => "#{ply.name} returned a #{card.readable_name} to the supply.",
                            :css_class => "player#{ply.seat}")
      # Do we have more discards allowed?  Queue up an action for them
      if ( params[:remain].to_i > 1 )
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_returncard;chosen=#{card.class.name};remain=#{params[:remain].to_i-1}",
                                                :text => "Return another card with Ambassador")
        parent_act.player = player
        parent_act.game = game
        parent_act.save!
        return "OK"
      end

    end

    # Ok, we're done returning cards to the supply - now queue the attack to give everyone else one
    attack(parent_act, :chosen => params[:chosen])
  end
  
  def attackeffect(params)
    # Effect of the attack succeeding - that is, give the player a copy of the returned card, if any remain
    target = Player.find(params[:target])
    parent_act = params[:parent_act]
    
    pile = game.piles.find_by_card_type(params[:chosen])
    if pile.empty?
      game.histories.create!(:event => "#{target.name} could not gain a #{params[:chosen].readable_name}, as there are none left.",
                            :css_class => "player#{target.seat} card_gain")
    else
      game.histories.create!(:event => "#{target.name} gained a copy due to Ambassador.",
                            :css_class => "player#{target.seat} card_gain")
      target.queue(parent_act, :gain, :pile => pile.id)
    end

    return "OK"
    
  end

end
