# 20  Explorer  Seaside  Action  $5  You may reveal a Province card from your hand. If you do, gain a Gold card, putting it into your hand. Otherwise, gain a Silver card, putting it into your hand.

class Seaside::Explorer < Card
  costs 5
  action
  card_text "Action (cost: 5) - You may reveal a Province card from your hand. If you do, gain a Gold card, putting it into your hand. Otherwise, gain a Silver card, putting it into your hand."
  
  # * On Play, ask the player to choose a province card in hand
  # * On resolution of that choice, if they chose a province, give them a gold, otherwise a silver.
  def play(parent_act)
    super
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}",
                                     :text => "Choose a province to reveal")
    act.player = player
    act.game = game
    act.save!
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    # This is the Explorer's controller choosing a Province card
    controls[:hand] += [{:type => :button,
                         :action => :resolve,
                         :name => "choose",
                         :text => "Choose",
                         :nil_action => "Choose no Province",
                         :params => {:card => "#{self.class}#{id}"},
                         :cards => player.cards.hand.map do |card|
                           card.class == BasicCards::Province
                         end
                        }] 
  end
  
  def resolve(ply, params, parent_act)
    # Player has made a choice of what to reveal.
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and 
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))            
      # Asked to play an invalid card (out of range)        
      return "Invalid request - card index #{params[:card_index]} is out of range"
    elsif params.include? :card_index and ply.cards.hand[params[:card_index].to_i].class != BasicCards::Province
      # Asked to play an invalid card (not a province)
      return "Invalid request - card index #{params[:card_index]} is not a province"
    end
    
    # Now process the card chosen (code based on Trading Post)
    if params[:nil_action]
      # Player has chosen to reveal nothing. Give them a silver.
      game.histories.create!(:event => "#{ply.name} chose to reveal no card, and gained a Silver to hand.",
                            :css_class => "player#{ply.seat}")
      # Get a silver card from the pile
      silver_pile = game.piles.find_by_card_type("BasicCards::Silver")
      ply.queue(parent_act, :gain, :pile => silver_pile.id, :location => "hand")
    else
      # Player chose a card. Give them a gold.
      game.histories.create!(:event => "#{ply.name} revealed a Province, and gained a Gold to hand.",
                            :css_class => "player#{ply.seat}")
      # Get a gold card from the pile
      gold_pile = game.piles.find_by_card_type("BasicCards::Gold")
      ply.queue(parent_act, :gain, :pile => gold_pile.id, :location => "hand")
    end
    
    save!
    
    return "OK"
  end
  
end
