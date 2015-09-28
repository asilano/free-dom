# 18        Treasure Map        Seaside        Action        $4        Trash this and another copy of Treasure Map from your hand. If you do trash two Treasure Maps, gain 4 Gold cards, putting them on top of your deck.

class Seaside::TreasureMap < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash this and another copy of Treasure Map from your hand. If you do trash two Treasure Maps, gain 4 Gold cards, putting them on top of your deck."

  def play(parent_act)
    super

    # Note the player and our current location before we trash ourselves
    ply = player
    already_trashed = (location == "trash")
    # Trash this card, and look for another Treasure Map in hand
    trash
    other = ply.cards(true).hand.of_type("Seaside::TreasureMap").first

    if other
      # Found a second Treasure Map
      other.trash
      game.histories.create!(:event => "#{ply.name} trashed #{already_trashed ? "another Treasure Map" : "two Treasure Maps"} from hand.",
                            :css_class => "player#{ply.seat} card_trash")

      if !already_trashed
        # Really trashed two maps: acquire the FOUR gold to top of deck.
        gold_pile = game.piles.find_by_card_type("BasicCards::Gold")
        4.times do
          ply.gain(parent_act, :pile => gold_pile, :location => "deck")
        end

        game.histories.create!(:event => "#{ply.name} gained four Gold to top of their deck.",
                              :css_class => "player#{ply.seat} card_gain")
      end
    else
      # No other Treasure Map exists.
      if already_trashed
        game.histories.create!(:event => "#{ply.name} couldn't trash any Treasure Maps.",
                              :css_class => "player#{ply.seat}")
      else
        game.histories.create!(:event => "#{ply.name} trashed only one Treasure Map.",
                              :css_class => "player#{ply.seat} card_trash")
      end
    end

    return "OK"
  end

end

