# 10	Warehouse	Seaside	Action	$3	+3 Card, +1 Action, Discard 3 cards.

class Seaside::Warehouse < Card
  costs 3
  action
  card_text "Action (cost: 3) - Draw 3 cards, +1 Action. Discard 3 cards."
  
  def play(parent_act)
    super
		
		# First, draw the cards.
    player.draw_cards(3)
        
    # Now create the new Action
    parent_act = player.add_actions(1, parent_act)

		# If the player has very few cards in deck, it's possible for the draw to fail, and
		# thus there to be fewer than 3 cards available to discard.
		
		num_discards = [3, player.cards.hand.length].min
		
		if ( 0 == num_discards )
			# Just log that we're out of cards
      game.histories.create!(:event => "#{player.name} discarded no cards to Warehouse, due to having none.",
                            :css_class => "player#{player.seat} card_discard")
    elsif (num_discards == player.cards.hand.length)
      # Only got as many cards as we need to discard, so discard them all.
      player.cards.hand.each do |card|
        card.discard
        game.histories.create!(:event => "#{player.name} discarded #{card}.",
                              :css_class => "player#{player.seat} card_discard")
      end
    elsif (player.cards.hand.map(&:class).uniq.length == 1)
      # Only one type of card in hand, so discard without question
      (1..num_discards).each do |ix|
        card = player.cards.hand[-ix]
        card.discard
        game.histories.create!(:event => "#{player.name} discarded #{card}.",
                              :css_class => "player#{player.seat} card_discard")
      end
		else
			# Queue up the requests to do the discards
			1.upto(num_discards) do |num|
				parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
				                                        :text => "Discard #{num} card#{num > 1 ? 's' : ''}",
                                                :player => player, 
                                                :game => game)
			end
		end
		
    return "OK"
  end
	
  def determine_controls(player, controls, substep, params)
    # determine_react_controls(player, controls, substep, params)
    
    #case substep
    #when "discard"
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
    #end
  end  

  def resolve_discard(ply, params, parent_act)
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

