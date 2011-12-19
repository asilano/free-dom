# 18        Treasure Map        Seaside        Action        $4        Trash this and another copy of Treasure Map from your hand. If you do trash two Treasure Maps, gain 4 Gold cards, putting them on top of your deck.

class Seaside::TreasureMap < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash this and another copy of Treasure Map from your hand. If you do trash two Treasure Maps, gain 4 Gold cards, putting them on top of your deck."
  
  def play(parent_act)
    super

    # Trash this card, and look for another Tresaure Map in hand
    trash
    other = player.cards.hand(true).of_type("Seaside::TreasureMap")[0]
    
    if other
      # Found a second treasure map
      game.histories.create!(:event => "#{player.name} trashed two Treasure Maps from hand.",
                            :css_class => "player#{player.seat} card_trash")
      other.trash

      # And acquire the FOUR gold to top of deck.
      gold_pile = game.piles.find_by_card_type("BasicCards::Gold")
      4.times do
        player.queue(parent_act, :gain, :pile => gold_pile.id, :location => "deck")
      end
      
      game.histories.create!(:event => "#{player.name} gained four Gold to top of their deck.", 
                            :css_class => "player#{player.seat} card_gain")
    else
      # No other treasure map exists.
      game.histories.create!(:event => "#{player.name} trashed only one treasure map.",
                            :css_class => "player#{player.seat} card_trash")
    end

    return "OK"
  end
 
end

