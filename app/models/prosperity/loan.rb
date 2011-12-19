# Loan (Treasure - $3) - 1 Cash. When you play this, reveal cards from your deck until you reveal a Treasure. Discard it or trash it. Discard the other cards.

class Prosperity::Loan < Card
  treasure :special => true
  costs 3
  card_text "Treasure (cost: 3) - 1 Cash. When you play this, reveal cards from your deck until you reveal a Treasure. Discard it or trash it. Discard the other cards."

  def play_treasure(parent_act)
    super
    
    player.cash += 1
    player.save!
  
    # This is quite similar to Adventurer
    # We don't really need to actually reveal the cards here; putting them
    # straight onto discard will work fine, with one caveat. We need to know
    # whether the existing discard pile will get shuffled under the deck first.
    #
    # So, step through the deck looking for Treasures. If we don't find one,
    # shuffle the discard pile under. Then step through the deck (possibly plus 
    # old discard) and move each card to discard until we're done.
    treasure_count = 0
    for card in player.cards.deck(true)
      treasure_count += 1 if card.is_treasure?
      break if treasure_count == 1
    end
    
    shuffle_point = player.cards.deck.count
    if treasure_count < 1
      player.shuffle_discard_under_deck(:log => shuffle_point == 0)
    end
    
    treasure_count = 0
    cards_revealed = []
    player.cards.in_discard(true)
    for card in player.cards.deck      
      if card.is_treasure?
        treasure_count = 1
        
        # Log what we revealed so far.
        if shuffle_point > 0 && shuffle_point < cards_revealed.length
          cards_revealed.insert(shuffle_point, "(#{player.name} shuffled their discards)")
        end
        game.histories.create!(:event => "#{player.name}'s #{readable_name} revealed: #{cards_revealed.join(', ')}.", 
                              :css_class => "player#{player.seat} card_reveal #{'shuffle' if (shuffle_point > 0 && shuffle_point < cards_revealed.length)}"
                              ) unless cards_revealed.empty?
                          
        # We know that the top card of the deck is a treasure. Reveal it, so we can hook an action to it
        player.reveal_from_deck(1)
        parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                   :text => "Choose to Trash or Discard #{player.cards.revealed[0].readable_name}",
                                   :player => player,
                                   :game => game)
        break
      else
        cards_revealed << card.class.readable_name        
        card.discard
      end      
    end
    
    if treasure_count == 0
      # Didn't find a treasure. Log the revealed cards
      if shuffle_point > 0 && shuffle_point < cards_revealed.length
          cards_revealed.insert(shuffle_point, "(#{player.name} shuffled their discards)")
        end
      game.histories.create!(:event => "#{player.name}'s #{readable_name} revealed: #{cards_revealed.empty? ? 'nothing' : cards_revealed.join(', ')}.", 
                            :css_class => "player#{player.seat} card_reveal #{'shuffle' if (shuffle_point > 0 && shuffle_point < cards_revealed.length)}")
    end
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep    
    when "choose"
      controls[:revealed] += [{:player_id => player.id,
                               :type => :two_d_radio,
                               :action => :resolve,
                               :text => "Confirm",
                               :options => ["Trash", "Discard"],
                               :params => {:card => "#{self.class}#{id}",
                                           :substep => "choose"},
                               :cards => [true]
                              }]
    end                        
  end
  
  def resolve_choose(ply, params, parent_act)
    # The control is a radio-button array, and hence we expect to have received
    # a :choice_#{self.class}#{id}, which may be "nil_action" or may be of the form
    # "card_index.option_index".
    if not params.include?(:choice)
      return "Invalid parameters"
    end
    
    if params[:choice] !~ /^[0-9]+\.[0-9]+$/
       return "Invalid request - choice '#{params[:choice]}' is not of the correct form"
    end
   
    card_index, option_index = params[:choice].scan(/([0-9]+)\.([0-9]+)/)[0].map {|i| i.to_i}
    
    if card_index > 0
      # Asked to move an invalid card
      return "Invalid request - card index #{card_index} is greater than number of revealed cards"
    elsif option_index > 1
      # Asked to do something invalid with a card
      return "Invalid request - option index #{option_index} is greater than number of options"
    end
    
    # Everything checks out. Do the requested action with the specified card.
    card = ply.cards.revealed[card_index]
    if option_index == 0
      # Chose to trash the card
      card.trash
      game.histories.create!(:event => "#{ply.name} chose to trash their #{card.readable_name}.", 
                            :css_class => "player#{ply.seat} card_trash")
    else
      # Chose to discard the card.        
      card.discard
      game.histories.create!(:event => "#{ply.name} chose to discard their #{card.class.readable_name}.",
                            :css_class => "player#{ply.seat} card_discard")
    end
    
    return "OK"
  end
end