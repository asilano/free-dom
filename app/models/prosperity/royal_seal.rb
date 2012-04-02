# RoyalSeal (Treasure - $5) - 2 Cash. While this is in play, when you gain a card, you may put that card on top of your deck.

class Prosperity::RoyalSeal < Card
  treasure :cash => 2
  costs 5
  card_text "Treasure (cost: 5) - 2 Cash. While this is in play, when you gain a card, you may put that card on top of your deck."
  
  def determine_controls(ply, controls, substep, params)
    case substep
    when "choose"
      card = Card.find(params[:gaining])
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :name => "choose",
                             :label => "#{self}: Place #{card}...:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "choose"}.merge(params),
                             :options => [{:text => "#{params[:location].titleize}",
                                           :choice => "normal"},
                                          {:text => "On deck",
                                           :choice => "deck"}]
                            }]
    end
  end
  
  def resolve_choose(ply, params, parent_act)
    # We expect to have a :choice parameter, either "deck" or "normal"
    if (not params.include? :choice) or
       (not params[:choice].in? ["deck", "normal"])
      return "Invalid parameters"
    end
           
    to_del = game.pending_actions.select {|pa| pa.expected_action =~ /;gaining=[0-9]+/}
           
    card = Card.find(params[:gaining])
    if params[:choice] == "normal"
      # If no-one else is trying to replace the gain, perform the default action here.
      if to_del.empty?
        card.gain(ply, parent_act, params[:location], params[:position].to_i)
      end
    else      
      # We're replacing the Gain, so scrap any other actions looking to replace it
      to_del.each do |pa| 
        raise "Destroying gain replacement action with children" unless pa.children.empty?
        pa.destroy
      end
      
      game.histories.create!(:event => "#{ply.name} placed #{card} on their deck with #{self}.",
                            :css_class => "player#{ply.seat}")
      
      # Call Card#gain directly with the stated choice (to avoid an infinite loop!)
      card.gain(ply, parent_act, "deck")
    end
    
    return "OK"
  end
end