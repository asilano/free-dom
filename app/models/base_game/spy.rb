class BaseGame::Spy < Card
  costs 4
  action :attack => true, :affects_attacker => true
  card_text "Action (Attack; cost 4) - Draw 1 card, +1 Action. Each player (including you)" +
    " reveals the top card of his or her deck and either discards it or puts " +
    "it back, your choice."
  
  def play(parent_act)
    super
    
    # First, draw a card.
    player.draw_cards(1)
    
    # Now create one new Action
    # The new Action shouldn't be available until the attack has been completed,
    # so we need to hang the attack off the new action
    parent_act = player.add_actions(1, parent_act)
    
    # Then conduct the attack
    attack(parent_act)
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)
    
    case substep    
    when "choose"
      # This is the attacker deciding what to do with the revealed card from
      # one target.
      # We ask for a "2D radio array" - that is, each card has a number of 
      # options provided; but only one option /in total/ can be selected
      target = Player.find(params[:target])
      controls[:revealed] += [{:player_id => target.id,
                               :type => :two_d_radio,
                               :action => :resolve,
                               :text => "Confirm",
                               :options => ["Discard", "Put back"],
                               :nil_action => 
                                  (target.cards.revealed.empty? ? "Do nothing" : nil),
                               :params => {:card => "#{self.class}#{id}",
                                           :substep => "choose",
                                           :target => target.id},
                               :cards => [true] * target.cards.revealed.size
                              }]
    end                        
  end
  
  def attackeffect(params)
    # Effect of the attack succeeding - that is, reveal the top card of the
    # target's deck, and ask the attacker to leave it or put it back.
    target = Player.find(params[:target])
    source = Player.find(params[:source])
    parent_act = params[:parent_act]
    
    # Get the attack target to reveal the top card from their deck
    target.reveal_from_deck(1)
    
    # And hang an action off the parent to ask the attacker to choose to leave 
    # it or discard it
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose;target=#{target.id}",
                                     :text => "Choose Spy actions for #{target.name}")
    act.player = source
    act.game = game
    act.save!
    
    return "OK"
  end
  
  def resolve_choose(ply, params, parent_act)
    # This is at the scope of the attacker, and represents their choice of what
    # to do with the revealed cards from each attackee.
    # The control is a radio-button array, and hence we expect to have received
    # a :choice_#{self.class}#{id}, which may be "nil_action" or may be of the form
    # "card_index.option_index".
    if not params.include?(:choice)
      return "Invalid parameters"
    end
    
    target = Player.find(params[:target])
    
    if params[:choice] != "nil_action" and
       params[:choice] !~ /^[0-9]+\.[0-9]+$/
       return "Invalid request - choice '#{params[:choice]}' is not of the correct form"
    end
   
    if params[:choice] == "nil_action"
      # Attacker chose to do nothing, which must be because there were no
      # revealed cards.       
      if not target.cards.revealed.empty?
        return "Invalid request - must choose to discard or put back"
      end
      
      game.histories.create!(:event => "#{target.name} revealed no card to the Spy, so #{ply.name} did nothing.",
                            :css_class => "player#{target.seat}")
    else
      card_index, option_index = params[:choice].scan(/([0-9]+)\.([0-9]+)/)[0].map {|i| i.to_i}
      
      if card_index > 0
        # Asked to move an invalid card
        return "Invalid request - card index #{card_index} is greater than number of revealed cards"
      elsif option_index > 1
        # Asked to do something invalid with a card
        return "Invalid request - option index #{option_index} is greater than number of options"
      end
      
      # Everything checks out. Do the requested action with the specified card.
      card = target.cards.revealed[card_index]
      if option_index == 0
        # Chose to discard the card.  
        card.discard
        game.histories.create!(:event => "#{ply.name} chose to discard #{target.name}'s #{card.class.readable_name}.",
                              :css_class => "player#{ply.seat} player#{target.seat} card_discard")
      else
        # Chose to put the card back. Just un-reveal it.        
        card.revealed = false
        card.save!
        game.histories.create!(:event => "#{ply.name} chose to put #{target.name}'s #{card.class.readable_name} back.",
                              :css_class => "player#{ply.seat} player#{target.seat}")
      end
    end
    
    return "OK"
  end
end
