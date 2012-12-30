class Hinterlands::Scheme < Card
  action
  costs 3
  card_text "Draw 1 card, +1 Action. At the start of Clean-up this turn, you may choose an Action card you have in play. " +
            "If you discard it from play this turn, put it on your deck."
            
  def play(parent_act)
    super
    
    # Simple stuff happens here
    player.draw_cards(1)
    player.add_actions(1, parent_act)
    
    # The end-of-turn action is added in Player#end_turn
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "return"
      controls[:play] += [{:type => :button,
                           :action => :resolve,
                           :text => "Choose",
                           :nil_action => "Choose nothing",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "return"},
                           :cards => player.cards.in_play.map do |card|
                             card.is_action?
                           end
                          }]
    end
  end
  
  def resolve_return(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if !params.include?(:nil_action) && !params.include?(:card_index)
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.in_play.length - 1))
      # Asked to return an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    if params.include? :nil_action
      # Not returning anything; just log
      game.histories.create(:event => "#{ply.name} chose not to return anything with #{self}",
                            :css_class => "player#{ply.seat}")
                            
      return "OK"
    end
    
    card = ply.cards.in_play[params[:card_index].to_i]
    if !card.is_action?
      # Asked to return a non-action
      return "Invalid request - #{card.readable_name} is not an Action"
    end

    # All good. put the chosen card on top of the deck
    card.location = "deck"
    card.position = -1
    card.save!
    
    game.histories.create(:event => "#{ply.name} put #{card} on top of his deck with #{self}",
                          :css_class => "player#{ply.seat}")
                          
    return "OK"
  end
end