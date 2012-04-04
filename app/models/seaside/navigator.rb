# 14  Navigator  Seaside  Action  $4  +2 Coins, Look at the top 5 cards of your deck. Either discard all of them, or put them back on top of your deck in any order.

class Seaside::Navigator < Card
  costs 4
  action
  card_text "Action (cost: 4) - +2 Cash. Look at the top 5 cards of your deck. Either discard all of them, or put them back on top of your deck in any order."

  def play(parent_act)
    super
    
    player.add_cash(2)
    
    # Look at the top 5 cards of the deck.
    num_seen = player.peek_at_deck(5, :top).length
    
    if (num_seen != 0)
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                 :text => "Choose whether to discard the seen cards with Navigator",
                                 :player => player,
                                 :game => game)
    end
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "choose"
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :name => "choose",
                             :label => "#{readable_name}:",                             
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "choose"},
                             :options => [{:text => "Discard seen cards",            
                                           :choice => "discard"},
                                          {:text => "Don't discard (choose order)",
                                           :choice => "keep"},
                                          {:text => "Don't discard (keep order)",
                                           :choice => "replace"}]
                              }]
    when "place"      
      controls[:peeked] += [{:player_id => player.id,
                           :type => :button,
                           :action => :resolve,
                           :name => "place",
                           :text => "Place #{ActiveSupport::Inflector.ordinalize(params[:posn])}",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "place",
                                       :posn => params[:posn]},
                           :cards => [true] * player.cards.peeked.length
                          }]
    end
  end
  
  def resolve_choose(ply, params, parent_act)
    # We expect to have a :choice parameter, "discard", "keep" or "replace"
    if (not params.include? :choice) or
       (not params[:choice].in? ["discard", "keep", "replace"])
      return "Invalid parameters"
    end
    
    # Everything looks fine. Carry out the requested choice
    if params[:choice] == "keep"
      # Chose not to discard the top of their deck, and specify the order. Create a history
      game.histories.create!(:event => "#{ply.name} chose not to discard the seen cards.",
                             :css_class => "player#{ply.seat}")
                            
      if ply.cards.peeked.length == 1
        # Only one card - it has to go on top. In fact, it already is, so just log and unpeek it.
        card = player.cards.peeked[0]
        game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card}|a card] on top of their deck.",
                               :css_class => "player#{ply.seat}")
        card.peeked = false
        card.save!      
      elsif player.cards.peeked.length > 1                    
        # Create pending actions to put the remaining cards back in any
        # order. We don't need an action for the last one.
        (2..player.cards.peeked.length).each do |ix|      
          parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place;posn=#{ix}",
                                                  :text => "Put a card #{ActiveSupport::Inflector.ordinalize(ix)} from top with #{readable_name}",
                                                  :player => player,
                                                  :game => game)
        end
      end            
    elsif params[:choice] == "replace"
      # Chose not to discard the top of their deck, and leave in current order.
      game.histories.create!(:event => "#{ply.name} chose not to discard the seen cards.",
                             :css_class => "player#{ply.seat}")
                             
      # Unreveal the cards from last to first, writing individual histories. That way it will look identical
      # to the manual mode.
      peeked_cards = ply.cards.peeked
      peeked_cards.reverse.each do |card|
        card.peeked = false
        card.save
        game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card}|a card] on top of their deck.",
                               :css_class => "player#{ply.seat}")
      end
    else
      peeked_cards = ply.cards.peeked
      peeked_cards.each do |card|
        card.discard
      end
      
      # And create a history
      game.histories.create!(:event => "#{ply.name} put [#{ply.id}?#{peeked_cards.map {|c| c.readable_name}.join(', ')}|the cards] onto their discard pile.",
                            :css_class => "player#{ply.seat}")
    end
    
    return "OK"
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
         params[:card_index].to_i > ply.cards.peeked.length - 1))            
      # Asked to place an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"    
    end
    
    # All checks out. Place the selected card on top of the deck (position -1),
    # unpeek it, and renumber.
    card = ply.cards.peeked[params[:card_index].to_i]    
    card.location = "deck"
    card.position = -1
    card.peeked = false
    card.save!
    game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card.class.readable_name}|a card] #{ActiveSupport::Inflector.ordinalize(params[:posn])} from top.",
                          :css_class => "player#{ply.seat}")
                          
    if params[:posn].to_i == 2
      # That was the card second from top, so only one card remains to be placed. Do so.
      raise "Wrong number of revealed cards" unless ply.cards.peeked(true).count == 1
      card = ply.cards.peeked[0]
      card.location = "deck"
      card.position = -2
      card.peeked = false
      card.save!
      game.histories.create!(:event => "#{ply.name} placed [#{ply.id}?#{card.class.readable_name}|a card] on top of their deck.",
                            :css_class => "player#{ply.seat}")
    end                      
    
    return "OK"
  end
  
end

