# 8	Lookout	Seaside	Action	$3	+1 Action, Look at the top 3 cards of your deck. Trash one of them. Discard one of them. Put the other one on top of your deck.

class Seaside::Lookout < Card
  costs 3
  action
  card_text "Action (cost: 3) - +1 Action. Look at the top 3 cards of your deck. Trash one of them. Discard one of them. Put the other one on top of your deck."

  
  def play(parent_act)
    super
    
    parent_act = player.add_actions(1, parent_act)
    num_seen = player.peek_at_deck(3, :top).length
    
    if (num_seen == 1)
      # Only one card seen; have to trash it.
      card = player.cards.deck[0]
      card.trash
      
      game.histories.create!(:event => "#{player.name} trashed the only card in his deck, #{card.readable_name}.", 
                            :css_class => "player#{player.seat} card_trash")
    elsif (num_seen > 0)
      # Need to provide options.
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                 :text => "Decide where to place each card, with #{readable_name}",
                                 :player => player,
                                 :game => game)
    end
    
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "choose"
      controls[:peeked] += [{:type => :latin_radio,
                           :action => :resolve,
                           :text => "Confirm",
                           :options => ["Trash", "Discard"] + (player.cards.peeked.length == 3 ? ["Deck"] : []),
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "choose"},
                           :cards => [true] * player.cards.peeked.length
                          }]
    end
  end
  
  def resolve_choose(ply, params, parent_act)
    # We expect to receive a "choose" parameter
    if !params.include?(:choice)
      return "Missing parameter"
    end
    
    # The parameter should be an array of two or three integers according to the peeked length
    if params[:choice].length != ply.cards.peeked.length
      return "Please choose an option for each of the cards"
    end
    
    # Process each choice in turn. We can enforce validity and uniqueness here.
    trashed = false
    discarded = false
    decked = false
    
    peeked_cards = ply.cards.peeked
    
    params[:choice].each do |card_ix, choice|
      if (card_ix.to_i < 0) ||
         (card_ix.to_i > peeked_cards.length - 1)            
        # Asked to do something with an invalid card (out of range)        
        return "Invalid request - card index #{card_ix} is out of range"
      end
      
      card = peeked_cards[card_ix.to_i]
      
      case choice
      when "0"
        # "Trash"
        if trashed
          return "Please choose unique options"
        end
        
        trashed = true
        card.trash
        
        game.histories.create!(:event => "#{ply.name} trashed #{card.readable_name}.",
                              :css_class => "player#{ply.seat} card_trash")
      when "1"
        # "Discard"
        if discarded
          return "Please choose unique options"
        end
        
        discarded = true        
        card.discard
        
        game.histories.create!(:event => "#{ply.name} discarded #{card.readable_name}.",
                              :css_class => "player#{ply.seat}")
      when "2"
        # "Deck"
        if peeked_cards.length != 3
          # Shouldn't have this option
          return "Can't put one of only 2 cards on your deck"
        end
        if decked
          return "Please choose unique options"          
        end
        decked = true
        
        # Since the other two cards have moved, putting this one on the deck
        # is a no-op. Just un-peek it.
        card.peeked = false
        card.save!      
        game.histories.create!(:event => "#{ply.name} put [#{ply.id}?#{card.readable_name}|a card] back on their deck.",
                              :css_class => "player#{ply.seat}")
      end
    end
   
    return "OK"
  end
  
end
