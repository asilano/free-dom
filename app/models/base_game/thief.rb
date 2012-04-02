class BaseGame::Thief < Card
  costs 4  
  action :attack => true
  card_text "Action (Attack; cost: 4) - Each other player reveals the top two cards of his deck. " +
      "If they revealed any Treasure cards, they trash one of them that you choose. " +
      "You may gain any or all of the trashed cards. They discard the other revealed cards."
  
  def play(parent_act)
    super
         
    # Just conduct the attack
    attack(parent_act)
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)
    
    case substep    
    when "choose"
      # This is the attacker deciding what to do with the revealed cards from
      # one target
      # We ask for a "2D radio array" - that is, each card has a number of 
      # options provided; but only one option /in total/ can be selected
      target = Player.find(params[:target])
      controls[:revealed] += [{:player_id => target.id,
                               :type => :two_d_radio,
                               :action => :resolve,
                               :text => "Confirm",
                               :options => ["Just Trash", "Trash and Take"],
                               :nil_action => nil,
                               :params => {:card => "#{self.class}#{id}",
                                           :substep => "choose",
                                           :target => target.id},
                               :cards => target.cards.revealed.map do |card|
                                  card.is_treasure?
                               end
                              }]
    end                        
  end
  
  def attackeffect(params)
    # Effect of the attack succeeding - that is, reveal the top two cards of
    # the target's deck, and ask the attacker to pick a treasure.
    target = Player.find(params[:target])
    source = Player.find(params[:source])
    parent_act = params[:parent_act]
    
    # Get the attack target to reveal the top two cards from their deck
    target.reveal_from_deck(2)
    
    if target.cards.revealed.any? {|c| c.is_treasure?}    
      # Hang an action off the parent to ask the attacker to choose a card
      # to trash or take
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose;target=#{target.id}",
                                       :text => "Choose Thief actions for #{target.name}",
                                       :player => source,
                                       :game => game)
    else
      # Neither card is a treasure. Call resolve_choose directly with nil_action
      return resolve_choose(source, {:choice => "nil_action",
                              :target => target.id},
                     parent_act)
    end
    
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
      # Attacker chose not to trash either card. We'll discard them both below,
      # so just create a history entry here.
      #
      # This is an invalid option if at least one of the revealed cards is
      # actually a Treasure
      if target.cards.revealed.any? {|c| c.is_treasure?}
        return "Invalid request - must choose to trash or take a Treasure card"
      end
      
      game.histories.create!(:event => "#{ply.name} chose to trash neither of #{target.name}'s cards.",
                            :css_class => "player#{ply.seat} player#{target.seat} card_trash")
    else
      card_index, option_index = params[:choice].scan(/([0-9]+)\.([0-9]+)/)[0].map {|i| i.to_i}
      
      if card_index > 1
        # Asked to trash/take an invalid card
        return "Invalid request - card index #{card_index} is greater than number of revealed cards"
      elsif option_index > 1
        # Asked to do something invalid with a card
        return "Invalid request - option index #{option_index} is greater than number of options"
      end
      
      # Everything checks out. Do the requested action with the specified card.
      card = target.cards.revealed[card_index]
      if option_index == 0
        # Chose to just trash the card.   
        game.cards.in_trash(true)
        card.trash
        game.histories.create!(:event => "#{ply.name} chose to trash #{target.name}'s #{card.class.readable_name}.",
                              :css_class => "player#{ply.seat} player#{target.seat} card_trash")
      else
        # Chose to steal the card.
        card.player = ply
        card.save!
        card.discard                
        game.histories.create!(:event => "#{ply.name} chose to steal #{target.name}'s #{card.class.readable_name}.",
                              :css_class => "player#{ply.seat} player#{target.seat}")
      end
    end
    
    # Discard the remaining cards.
    target.cards.revealed(true).each do |c|
      c.discard      
    end
    game.histories.create!(:event => "#{target.name} discarded the remaining revealed cards.",
                          :css_class => "player#{target.seat} card_discard")
    
    return "OK"
  end
end
