# Venture (Treasure - $5) - 1 Cash. When you play this, reveal cards from your deck until you reveal a Treasure. Discard the other cards. Play that Treasure

class Prosperity::Venture < Card
  treasure :special => true
  costs 5
  card_text "Treasure (cost: 5) - 1 Cash. When you play this, reveal cards from your deck until you reveal a Treasure. Discard the other cards. Play that Treasure"
  
  def play_treasure(parent_act)
    super
    
    player.cash += 1
    player.save
    
    # This is very similar to Adventurer. And Loan.
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
                          
        # We know that the top card of the deck is a treasure. Play it, bearing in mind it might be a special
        game.histories.create!(:event => "#{player.name} played #{card} via #{readable_name}.",
                              :css_class => "player#{player.seat} play_treasure")                                                          
        rc = card.play_treasure(parent_act)
        
        if !card.is_special?
          player.cash += card.cash
          player.save!
        end
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
end