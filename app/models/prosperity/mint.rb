# Mint (Action - $5) - You may reveal a Treasure card from your hand. Gain a copy of it. / When you buy this, trash all Treasures you have in play.

class Prosperity::Mint < Card
  action
  costs 5
  card_text "Action (cost: 5) - You may reveal a Treasure card from your hand. Gain a copy of it. / When you buy this, trash all Treasures you have in play."
  
  def play(parent_act)
    super
    
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_reveal",
                               :text => "Reveal a Treasure card from hand",
                               :player => player,
                               :game => game)
                               
    return "OK"                              
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "reveal"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "reveal",
                          :text => "Reveal",
                          :nil_action => "Reveal nothing",
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "reveal"},
                          :cards => player.cards.hand.map {|c| c.is_treasure?}
                         }]
    end
  end
  
  def resolve_reveal(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to trash an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end
    
    card = ply.cards.hand[params[:card_index].to_i]
    if !card.is_treasure?
      # Asked to copy a non-treasure
      return "Invalid request - #{card.readable_name} is not a Treasure"
    end
    
    # All checks out. Carry on
    if params.include? :nil_action
      game.histories.create!(:event => "#{ply.name} chose to copy nothing.",
                            :css_class => "player#{ply.seat}")
    else
      # Locate the pile for that treasure card.
      pile = game.piles.find_by_card_type(card.class.to_s)
      
      if !pile
        # Future-proof against Black Market
        game.histories.create!(:event => "#{ply.name} couldn't gain another #{card}, as it has no pile.",
                              :css_class => "player#{ply.seat}")
      elsif pile.empty?
        # Can't gain a copy - none left
        game.histories.create!(:event => "#{ply.name} couldn't gain another #{card}, as its pile is empty.",
                              :css_class => "player#{ply.seat}")
      else
        # Gain the copy. 
        game.histories.create!(:event => "#{ply.name} took a copy of #{card} with Mint.",
                              :css_class => "player#{ply.seat} card_gain")

        ply.queue(parent_act, :gain, :pile => pile.id)
      end
        
      return "OK"
    end
  end
  
end