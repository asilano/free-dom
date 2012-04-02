# CountingHouse (Action - $5) - Look through your discard pile, reveal any number of Copper cards from it, and put them into your hand.

class Prosperity::CountingHouse < Card
  action
  costs 5
  card_text "Action (Cost: 5) - Look through your discard pile, reveal any number of Copper cards from it, and put them into your hand."
  
  def play(parent_act)
    super
    
    if player.cards.in_discard.of_type("BasicCards::Copper").empty?
      # No Coppers to return. Just log.
      game.histories.create!(:event => "#{player.name} returned no Copper cards with #{readable_name}.",
                            :css_class => "player#{player.seat}")
    else                      
      # Just queue up the PendingAction
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_coppers",
                                 :text => "Choose the number of Coppers to return with #{readable_name}.",
                                 :player => player,
                                 :game => game)
    end
    
    return "OK"
  end
  
  def determine_controls(ply, controls, substep, params)
    case substep
    when "coppers"     
      num = player.cards.in_discard.of_type("BasicCards::Copper").length
      choices = 0.upto(num).map {|n| [n.to_s, n]}
      controls[:player] += [{:type => :dropdown,
                             :action => :resolve,
                             :name => 'choice',
                             :label => "How many Coppers?",
                             :choices => choices,
                             :selected => num,
                             :button_text => ["Return"],
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "coppers"}
                            }]
    end
  end
          
  def resolve_coppers(ply, params, parent_act)
    # We're expecting a count of coppers
    if !params.include? :choice
      return "Invalid parameters"
    end
    
    # We expect the count to be between 0 and the number of coppers in discard
    discarded_coppers = player.cards.in_discard.of_type("BasicCards::Copper")
    count = params[:choice].to_i
    if count < 0 || count > discarded_coppers.length
      return "Invalid number of Coppers #{count}. Must be between 0 and #{discarded_coppers.length}"      
    end
    
    # Right, all looks good. Move them Coppers.
    player.cards.hand(true)
    discarded_coppers[0, count].each do |copper|
      if player.cards.hand.empty?
        copper.position = 0
      else
        copper.position = player.cards.hand[-1].position + 1
      end
      player.cards.hand << copper
      copper.location = "hand"
      copper.save
    end
    
    game.histories.create!(:event => "#{player.name} returned #{count} Copper card#{'s' if count != 1} from their discard to their hand.",
                          :css_class => "player#{player.seat}")
                          
    return "OK"
  end
end