class Intrigue::Scout < Card
  costs 4
  action
  card_text "Action (cost: 4) - +1 Action. Reveal the top 4 cards of your deck. " +
            "Put the revealed Victory cards into your hand. Put the other cards " +
            "on top of your deck in any order."
            
  def play(parent_act)
    super
    
    # Grant the extra action
    parent_act = player.add_actions(1, parent_act)
    
    # Reveal the top 4 cards. We need to attach buttons to them, so really do
    # reveal them.
    player.reveal_from_deck(4)
    
    # Move any Victories into hand
    player.cards.hand(true)
    cards_moved = []
    player.cards.revealed.select {|c| c.is_victory?}.each do |vic|
      if player.cards.hand.empty?
        vic.position = 0
      else
        vic.position = player.cards.hand[-1].position + 1
      end
      player.cards.hand << vic
      vic.location = "hand"
      vic.revealed = false
      cards_moved << vic.readable_name      
      vic.save!
    end
    
    player.renum(:deck)  
      
    if not cards_moved.empty?
      game.histories.create!(:event => "#{player.name} put " +
                                      "#{cards_moved.join(', ')} " +
                                      "into their hand.",
                            :css_class => "player#{player.seat}")
    end
    
    if player.cards.revealed(true).length == 1
      # Only one other card - it has to go on top. In fact, it already is, so just log and unreveal it.
      card = player.cards.revealed[0]
      game.histories.create!(:event => "#{player.name} placed #{card} on top of their deck.",
                            :css_class => "player#{player.seat}")
      card.revealed = false
      card.save!      
    elsif player.cards.revealed.length > 1                    
      # Finally, create pending actions to put the remaining cards back in any
      # order. We don't need an action for the last one.
      (2..player.cards.revealed(true).length).each do |ix|      
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place;posn=#{ix}",
                                                :text => "Put a card #{ActiveSupport::Inflector.ordinalize(ix)} from top with #{readable_name}",
                                                :player => player,
                                                :game => game)
      end
    end
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "place"
      controls[:revealed] += [{:player_id => player.id,
                               :type => :button,
                               :action => :resolve,
                               :name => "place",
                               :text => "Place #{ActiveSupport::Inflector.ordinalize(params[:posn])}",
                               :params => {:card => "#{self.class}#{id}",
                                           :substep => "place",
                                           :posn => params[:posn]},
                               :cards => [true] * player.cards.revealed.length
                              }]
    end
  end
  
  def resolve_place(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if not params.include? :card_index
      return "Invalid parameters"
    end
    
    # Processing is surprisingly similar to a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.revealed.length - 1))            
      # Asked to discard an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"    
    end
    
    # All checks out. Place the selected card on top of the deck (position -1),
    # unreveal it, and renumber.
    card = ply.cards.revealed[params[:card_index].to_i]
    ply.cards.deck(true) << card
    card.location = "deck"
    card.position = -1
    card.revealed = false
    card.save!
    game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card.class.readable_name}|a card] #{ActiveSupport::Inflector.ordinalize(params[:posn])} from top.",
                          :css_class => "player#{ply.seat}")
                          
    if params[:posn].to_i == 2
      # That was the card second from top, so only one card remains to be placed. Do so.
      raise "Wrong number of revealed cards" unless ply.cards.revealed(true).count == 1
      card = ply.cards.revealed(true)[0]
      card.location = "deck"
      card.position = -2
      card.revealed = false
      card.save!
      game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card.class.readable_name}|a card] on top of their deck.",
                            :css_class => "player#{ply.seat}")
    end
    
    return "OK"
  end
end