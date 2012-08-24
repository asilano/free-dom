#24  Tactician  Seaside  Action  $5  Discard your hand. If you discarded any cards this way, then at the start of your next turn, +5 Cards, +1 Buy, and +1 Action.

class Seaside::Tactician < Card
  costs 5
  action :duration => true
  card_text "Action (Duration; Cost: 5) - Discard your hand. If you discarded any cards this way, then at the start of your next turn, +5 Cards, +1 Buy, and +1 Action."
  
  serialize :state

  def play(parent_act)
    super
    
    # State needs to be an array, because of Throne Room etc.
    self.state ||= []

    # Discard whole hand
    if player.cards.hand(true).empty?
      # Can't discard anything.
      game.histories.create!(:event => "#{player.name} couldn't discard anything as their hand was empty.",
                            :css_class => "player#{player.seat} card_discard")
      self.state << "no"
    else
      num = player.cards.hand.length
      player.cards.hand.each do |card|     
        card.discard 
      end
      
      game.histories.create!(:event => "#{player.name} discarded their hand to #{readable_name} (#{num} cards).",
                            :css_class => "player#{player.seat} card_discard")
      self.state << "yes"
    end
    
    save!
    
    return "OK"
  end

  def end_duration(parent_act)
    super

    # If we didn't discard, this does nothing
    raise "#{readable_name} has no state!" if state.empty?
    state_will_change!
    if (state.pop == "yes")
      # +5 cards
      player.draw_cards(5)

      # +1 buy
      player.add_buys(1, parent_act)
      
      # +1 action
      player.add_actions(1, parent_act)
    end

    save!

    return "OK"
  end

end

