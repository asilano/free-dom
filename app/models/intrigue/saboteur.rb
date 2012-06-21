class Intrigue::Saboteur < Card
  costs 5
  # Order becomes important if any pile has fewer cards than attacked players
  action :attack => true, 
         :order_relevant => lambda{|params| game.piles.any?{|p| p.cards.size < game.players.size - 1}}
  card_text "Action (Attack; cost: 5) - Each other player reveals cards from the top " +
            "of his deck until he reveals one costing 3 or more. He trashes " +
            "that card and may gain a card costing at most 2 less than it. He " +
            "discards the other revealed cards."
            
  def play(parent_act)
    super
    
    attack(parent_act)
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)
    
    case substep
    when "take"
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :name => "take",
                            :text => "Take",
                            :nil_action => "Take nothing",
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take",
                                        :trashed_cost => params[:trashed_cost]},
                            :piles => game.piles.map do |pile|
                              pile.cost <= (params[:trashed_cost].to_i - 2)
                            end
                          }]
    end
  end
  
  def attackeffect(params)
    # Effect of the attack succeeding - that is, "reveal" cards from the
    # target's deck until we find cost >= 3, trash, and ask to replace it.
    target = Player.find(params[:target])
    parent_act = params[:parent_act]
    
    # The revealing-until-we-hit-a-condition is very similar to BaseGame::Adventurer,
    # so this code is also similar.
    #
    # We don't really need to actually reveal the cards here; putting them
    # straight onto discard will work fine, with one caveat. We need to know
    # whether the existing discard pile will get shuffled under the deck first.
    #
    # So, check whether there are any? cards in deck with cost >= 3.
    shuffle_point = target.cards.deck.count
    if not target.cards.deck(true).any? {|c| c.cost >= 3}
      target.shuffle_discard_under_deck(:log => shuffle_point == 0)
    end
    
    cards_revealed = []    
    trashed_card = nil
    for card in target.cards.deck
      cards_revealed << card.class.readable_name
      if card.cost >= 3
        card.trash
        trashed_card = card
        break
      else        
        card.discard
      end      
    end
    
    # Create the history entry for the discards
    if shuffle_point > 0 && shuffle_point < cards_revealed.length
      cards_revealed.insert(shuffle_point, "(#{target.name} shuffled their discards)")
    end
    game.histories.create!(:event => "#{target.name} revealed: #{cards_revealed.join(', ')}.", 
                          :css_class => "player#{target.seat} card_reveal card_discard #{'shuffle' if (shuffle_point > 0 && shuffle_point < cards_revealed.length)}")
    
    if trashed_card
      # Target had to trash a card. Write a history, and set up a pending action
      # to take a replacement
      game.histories.create!(:event => "#{target.name} trashed #{trashed_card.readable_name}.", 
                            :css_class => "player#{target.seat} card_trash")
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take;trashed_cost=#{trashed_card.cost}",
                                 :text => "Take a replacement card with Saboteur",
                                 :player => target,
                                 :game => game)
    end  
    
    return "OK"    
  end
  
  def resolve_take(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :pile_index)
      return "Invalid parameters"
    end
    
    # Processing is pretty much the same as a buy; code shamelessly yoinked from
    # Player.buy.
    if ((params.include? :pile_index) and 
           (params[:pile_index].to_i < 0 or
            params[:pile_index].to_i > game.piles.length - 1))            
      # Asked to take an invalid card (out of range)        
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif (params.include? :pile_index) and 
          (not game.piles[params[:pile_index].to_i].cost <= (params[:trashed_cost].to_i - 2))
      # Asked to take an invalid card (too expensive)
      return "Invalid request - card #{game.piles[params[:pile_index]].card_type} is too expensive"
    end
    
    if params.include? :nil_action
      # Chose not to take a replacement. Just log it.
      game.histories.create!(:event => "#{ply.name} took no replacement with Saboteur.",
                            :css_class => "player#{ply.seat}")
    else
      # Process the take. Move the chosen card to the top of the discard pile
      # Get the card to do it, so that we mint a fresh instance of infinite cards
      game.histories.create!(:event => "#{ply.name} took " + 
             "#{game.piles[params[:pile_index].to_i].card_class.readable_name} as replacement with Saboteur.",
                            :css_class => "player#{ply.seat} card_gain")

      ply.gain(parent_act, game.piles[params[:pile_index].to_i].id)                      
    end
    
    return "OK"
  end
end
