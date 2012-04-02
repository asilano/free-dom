# Talisman (Treasure - $4) - 1 Cash. While this is in play, when you buy a card costing 4 or less that is not a Victory card, gain a copy of it.

class Prosperity::Talisman < Card
  treasure :cash => 1
  costs 4
  card_text "Treasure (cost: 4) - 1 Cash. While this is in play, when you buy a card costing 4 or less that is not a Victory card, gain a copy of it."
  
  # Player#buy catches the case of buying a non-Victory with a Talisman in play, and calls here.
  def self.bought_card(ply, num_talismans, pile, parent_act)
    return if num_talismans < 1
    
    game = ply.game
    
    # Player bought a non-Victory with at least one Hoard in play. Give the player that many copies of the card  
    game.histories.create!(:event => "#{ply.name} gained #{num_talismans} cop#{num_talismans > 1 ? 'ies' : 'y'} of #{pile.card_class.readable_name} from #{readable_name}.", 
                          :css_class => "player#{ply.seat} card_gain")

    num_talismans.times do |ix|
      ply.queue(parent_act, :gain, :pile => pile.id)      
    end       
  end
end