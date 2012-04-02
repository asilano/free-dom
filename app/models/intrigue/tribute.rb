class Intrigue::Tribute < Card
  costs 5
  action
  card_text "Action (cost: 5) - The player to your left discards the top 2 " +
            "cards of his deck. For each differently-named card discarded, if " +
            "it's an Action, +2 Actions; Treasure, +2 Cash; Victory, draw 2 cards."
            
  def play(parent_act)
    super
    
    # Pick up the "player to the left" - the next player
    tributer = player.next_player
    
    # Ensure they have 2 cards to discard, if possible
    shuffle_point = tributer.cards.deck.count
    if tributer.cards.deck(true).length < 2
      tributer.shuffle_discard_under_deck(:log => shuffle_point == 0)
    end
    
    # Move the top two cards to discard, noting what they are
    discarded_cards = []
    
    if tributer.cards.deck.length == 0
      # No cards
      game.histories.create!(:event => "#{tributer.name} had no cards in deck.", 
                            :css_class => "player#{tributer.seat}")
    else
      card = tributer.cards.deck[0]
      discarded_cards << card      
      card.discard
      
      if tributer.cards.deck(true).length == 0
        # No more cards
        game.histories.create!(:event => "#{tributer.name} had only one card in deck.", 
                              :css_class => "player#{tributer.seat}")
      else
        card = tributer.cards.deck[0]
        discarded_cards << card        
        card.discard
      end
      
      for_log = discarded_cards.dup
      
      if shuffle_point == 1
        for_log.insert(1, "(#{tributer.name} shuffled their discards)")
      end
      
      # Log and act on the discarded cards
      game.histories.create!(:event => "#{tributer.name} discarded #{for_log.join(', ')}.", 
                            :css_class => "player#{tributer.seat} card_discard #{'shuffle' if (shuffle_point == 1)}")
                            
      
      discarded_cards.map{|c| c.class}.uniq.each do |card|
        if card.is_action?
          parent_act = player.add_actions(2, parent_act)
          game.histories.create!(:event => "#{player.name} gained 2 actions from #{card.readable_name}.",
                                :css_class => "player#{player.seat}")
        end
        
        if card.is_treasure?
          player.add_cash(2)
          game.histories.create!(:event => "#{player.name} gained 2 cash from #{card.readable_name}.",
                                :css_class => "player#{player.seat}")
        end
        
        if card.is_victory?
          player.draw_cards(2," from #{card.readable_name}")
        end
      end
    end
    
    return "OK"
  end
end
