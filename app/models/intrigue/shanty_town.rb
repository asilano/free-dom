class Intrigue::ShantyTown < Card
  costs 3
  action
  card_text "Action (cost: 3) - +2 Actions. Reveal your hand. If you have no Action " +
                       "cards in hand, draw 2 cards."    

  def play(parent_act)
    super
    
    # A nice, simple card. No interaction. Hurrah.
    player.add_actions(2, parent_act)
    
    # "Reveal" the hand (actually, just stick it in history, since it doesn't
    # need to be persistently visible)
    game.histories.create!(:event => "#{player.name} revealed their hand to Shanty Town:", 
                          :css_class => "player#{player.seat} card_reveal")
    game.histories.create!(:event => "#{player.name} revealed #{player.cards.hand.join(', ')}.", 
                          :css_class => "player#{player.seat} card_reveal")
    
    if not player.cards.hand.any? {|c| c.is_action?}
      player.draw_cards(2)
    end
    
    return "OK"
  end
end
