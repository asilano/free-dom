# Vault (Action - $5) - Draw 2 Cards. Discard any number of cards; +1 cash per card discarded. Each other player may discard 2 cards; if he does, he draws a card.

class Prosperity::Vault < Card
  action
  costs 5
  card_text "Action (cost: 5) - Draw 2 Cards. Discard any number of cards; +1 cash per card discarded. Each other player may discard 2 cards; if he does, he draws a card."
  
  def play(parent_act)
    super
    
    player.draw_cards(2)
    parent_act.concurrent([
                            {:expected_action => "resolve_#{self.class}#{id}_discard",
                             :text => "Discard any number of cards, with #{self}",
                             :player => player,
                             :game => game}
                          ] + player.other_players.map do |ply|
                                {:expected_action => "resolve_#{self.class}#{id}_choose",
                                 :text => "Discard first card or choose not to, with #{self}",
                                 :player => ply,
                                 :game => game} unless ply.cards.hand.size < 2
                              end.compact)
                     
    "OK"
  end
  
  def determine_controls(ply, controls, substep, params)
    case substep
    when "discard"
      # Card's owner discarding any number of cards, exactly as for Secret Chamber
      controls[:hand] += [{:type => :checkboxes,
                           :action => :resolve,
                           :name => "discard",
                           :choice_text => "Discard",
                           :button_text => "Discard selected",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => [true] * ply.cards.hand.size
                          }]
    when "choose", "discardtwo"
      # An opponent choosing which card to discard first or (by discarding nothing) opting out
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :name => "discard",
                           :text => "Discard",
                           :nil_action => ("Discard nothing" unless substep == "discardtwo"),
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => substep},
                           :cards => [true] * ply.cards.hand.size
                          }]
    end
  end
  
  # Player of the card discarding for cash
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
      game.histories.create!(:event => "#{ply.name} discarded no cards to #{self}.",
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
      game.histories.create!(:event => "#{ply.name} discarded #{cards_discarded.join(', ')} with #{self}.",
                            :css_class => "player#{ply.seat} card_discard")
      
      # Add the same amount of Cash as cards discarded
      ply.cash += cards_discarded.length
      ply.save!
    end
    
    return "OK"
  end
  
  # An opponent discarding, or not, to trigger the request for the second discard
  def resolve_choose(ply, params, parent_act)
    # We should expect a :card_index or a :nil_action parameter
    if (not params.include? :nil_action) && (!params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Sanity checks - is the card in hand?
    if ((params.include? :card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to discard an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"    
    end
    
    # All looks good - process the request
    if params.include? :nil_action
      # :nil_action specified. Just log
      game.histories.create!(:event => "#{ply.name} chose not to discard.", 
                            :css_class => "player#{ply.seat}")      
    else
      # :card_index specified. Discard the specified card
      card = ply.cards.hand[params[:card_index].to_i]
      card.discard
      game.histories.create!(:event => "#{ply.name} discarded a #{card}.",
                            :css_class => "player#{ply.seat} card_discard")
                              
      if ply.cards.hand.count > 0
        # Player has more cards in hand, so must discard a second.
        parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discardtwo",
                                   :text => "Discard second card with #{self}",
                                   :player => ply,
                                   :game => game)
      else
        # Log that the player has no more cards
        game.histories.create!(:event => "#{ply.name} couldn't discard a second card as their hand was empty.",
                              :css_class => "player#{ply.seat}")
      end
    end
    
    return "OK"
  end
  
  def resolve_discardtwo(ply, params, parent_act)
    # We should expect a :card_index
    if (!params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Sanity checks - is the card in hand?
    if ((params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to discard an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"    
    end
    
    # All looks good - process the request
    # Discard the specified card
    card = ply.cards.hand[params[:card_index].to_i]
    card.discard
    game.histories.create!(:event => "#{ply.name} discarded a #{card}.",
                          :css_class => "player#{ply.seat} card_discard")
                            
    # And draw a replacement
    ply.draw_cards(1)
    
    return "OK"
  end
end