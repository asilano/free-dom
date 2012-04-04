# 4  Native Village  Seaside  Action  $2  +2 Actions, Choose one: Set aside the top card of your deck face down on your Native Village mat; or put all the cards from your mat into your hand.
# You may look at the cards on your mat at any time; return them to your deck at the end of the game.

class Seaside::NativeVillage < Card
  costs 2
  action
  card_text "Action (cost: 2) - +2 Actions. Choose one: Set aside the top card of your deck face down on your Native Village mat; or put all the cards from your mat into your hand."
  
  def play(parent_act)
    super
    
    parent_act = player.add_actions(2, parent_act)
    
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_mode",
                               :text => "Choose #{readable_name}'s mode",
                               :game => game,
                               :player => player)
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "mode"
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :name => "mode",
                             :label => "#{readable_name} mode:",                              
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "mode"},
                             :options => [{:text => "Set top card aside",              
                                           :choice => "setaside"},
                                          {:text => "Reclaim set-aside cards",
                                           :choice => "reclaim"}]
                            }] 
    end
  end
  
  def resolve_mode(ply, params, parent_act)
    # We expect to have a :choice parameter, either "discard" or "keep"
    if (not params.include? :choice) or
       (not params[:choice].in? ["setaside", "reclaim"])
      return "Invalid parameters"
    end
    
    # Everything looks fine. Carry out the requested choice
    if params[:choice] == "setaside"
      # Chose to set aside the top card of the deck - that is, move it to "native_village"
      if ply.cards.deck(true).size < 1 
        ply.shuffle_discard_under_deck
      end
      
      if ply.cards.deck.size >= 1
        card = ply.cards.deck[0]
        card.location = "native_village"
        card.save!
        
        game.histories.create!(:event => "#{ply.name} set [#{ply.id}?#{card.readable_name}|a card] aside from their deck.",
                              :css_class => "player#{ply.seat}")
      else
        game.histories.create!(:event => "#{ply.name} was unable to set a card aside, as their deck was empty.",
                              :css_class => "player#{ply.seat}")
      end
    else
      # Chose to reclaim the cards - that is, move all "native_village" cards to "hand"
      ply.cards.hand(true)
      ply.cards.in_location("native_village").each do |card|
        ply.cards.hand << card
        card.location = "hand"
        card.position = ply.cards.hand.size - 1
        card.save
      end
      
      # And create a history
      game.histories.create!(:event => "#{ply.name} reclaimed the cards from #{readable_name}.",
                            :css_class => "player#{ply.seat}")
    end
    
    return "OK"
  end
end

