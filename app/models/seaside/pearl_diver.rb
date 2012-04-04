# 5  Pearl Diver  Seaside  Action  $2  +1 Card, +1 Action, Look at the bottom card of your deck. You may put it on top.

class Seaside::PearlDiver < Card
  costs 2
  action
  card_text "Action (cost: 2) - Draw 1 card, +1 Action. Look at the bottom card of your deck. You may put it on top."
  
  def play(parent_act)
    super
    
    # A card and an action
    player.draw_cards(1)
    parent_act = player.add_actions(1, parent_act)
    
    # Look at the BOTTOM card of deck, and make a choice about it.
    num_seen = player.peek_at_deck(1, :bottom).length
    
    if player.cards.deck.count == 1
      # Saw only one card. Can't move it, so just unpeek it.
      game.histories.create!(:event => "#{player.name} saw the only card in their deck.",
                            :css_class => "player#{player.seat}")  

      player.cards.deck[0].peeked = false
      player.cards.deck[0].save!
    elsif (num_seen != 0)
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                 :text => "Choose whether to move the seen card with Pearl Diver",
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
                             :params => {:card => "#{self.class}#{id}"},
                             :options => [{:text => "Move #{player.cards.deck[-1].readable_name} to top of deck",
                                           :choice => "move"},
                                          {:text => "Leave #{player.cards.deck[-1].readable_name} on bottom of deck",
                                           :choice => "leave"}]
                            }] 
    end
  end
  
  def resolve(ply, params, parent_act)
    # We expect to have a :choice parameter, either "move" or "leave"
    if (not params.include? :choice) or
       (not params[:choice].in? ["move", "leave"])
      return "Invalid parameters"
    end
    
    # Everything looks fine. Carry out the requested choice
    card = ply.cards.deck(true)[-1]
    if params[:choice] == "leave"
      # Chose not to move the card to the top, so a no-op other than unpeeking.
      # Create a history
      game.histories.create!(:event => "#{ply.name} chose not to move the card to the top of their deck.",
                            :css_class => "player#{ply.seat}")

    else
      # Move the card to the top of the deck, and un-peek at it.      
      card.position = -1

      
      # And create a history
      game.histories.create!(:event => "#{ply.name} moved the bottom card of their deck to the top.",
                            :css_class => "player#{ply.seat}")
    end
    
    card.peeked = false
    card.save!
    
    return "OK" 
  end  
end

