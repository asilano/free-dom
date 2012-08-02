# 18        Treasure Map        Seaside        Action        $4        Trash this and another copy of Treasure Map from your hand. If you do trash two Treasure Maps, gain 4 Gold cards, putting them on top of your deck.

class Seaside::TreasureMap < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash this and another copy of Treasure Map from your hand. If you do trash two Treasure Maps, gain 4 Gold cards, putting them on top of your deck."
  
  def play(parent_act)
    super

    # We're about to trash this card, which will remove the reference to player; so take a local copy
    ply = player

    # Trash this card, and look for another Tresaure Map in hand
    trash
    other = ply.cards.hand(true).of_type("Seaside::TreasureMap")[0]
    
    if other
      # Found a second treasure map
      game.histories.create!(:event => "#{ply.name} trashed two Treasure Maps from hand.",
                            :css_class => "player#{ply.seat} card_trash")
      other.trash

      # And acquire the FOUR gold to top of deck.
      gold_pile = game.piles.find_by_card_type("BasicCards::Gold")
      4.times do
        ply.gain(parent_act, gold_pile.id, :location => "deck")
      end
      
      game.histories.create!(:event => "#{ply.name} gained four Gold to top of their deck.",
                            :css_class => "player#{ply.seat} card_gain")
    else
      # No other treasure map exists.
      game.histories.create!(:event => "#{ply.name} trashed only one #{readable_name}.",
                            :css_class => "player#{ply.seat} card_trash")
    end

    return "OK"
  end
 
end

