class BaseGame::Workshop < Card
  costs 3
  action
  card_text "Action (cost: 3) - Gain a card costing up to 4."
  
  def play(parent_act)
    super
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}",
                                     :text => "Take card with Workshop")
    act.player = player
    act.game = game
    act.save!
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    controls[:piles] += [{:type => :button,
                          :action => :resolve,
                          :name => "take",
                          :text => "Take",
                          :nil_action => nil,
                          :params => {:card => "#{self.class}#{id}"},
                          :piles => game.piles.map do |pile|
                            pile.cost <= 4 and not pile.empty?
                          end
                        }]
  end
  
  def resolve(ply, params, parent_act)
    # We expect to have been passed a :pile_index
    if not params.include? :pile_index
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a buy; code shamelessly yoinked from
    # Player.buy.
    if ((params.include? :pile_index) and 
           (params[:pile_index].to_i < 0 or
            params[:pile_index].to_i > game.piles.length - 1))            
      # Asked to take an invalid card (out of range)        
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif params.include? :pile_index and not game.piles[params[:pile_index].to_i].cost <= 4
      # Asked to take an invalid card (too expensive)
      return "Invalid request - card #{game.piles[params[:pile_index]].card_type} is too expensive"
    end
    
  
    # Process the take. Move the chosen card to the top of the discard pile
    # Get the card to do it, so that we mint a fresh instance of infinite cards
    game.histories.create!(:event => "#{ply.name} took " + 
           "#{game.piles[params[:pile_index].to_i].card_class.readable_name} from the Workshop.",
                          :css_class => "player#{ply.seat} card_gain")

    ply.queue(parent_act, :gain, :pile => game.piles[params[:pile_index].to_i].id)                       
    
    return "OK"
  end
  
end
