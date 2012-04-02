# Hoard (Treasure - $6) - 2 Cash. / While this is in play, when you buy a Victory card, gain a Gold.

class Prosperity::Hoard < Card
  treasure :cash => 2
  costs 6
  card_text "Treasure (cost: 6) - 2 Cash. / While this is in play, when you buy a Victory card, gain a Gold."

  # Player#buy catches the case of buying a Victory with a Hoard in play, and calls here.
  def self.bought_victory(ply, num_hoards, parent_act)
    return if num_hoards < 1
    
    game = ply.game
    
    # Player bought a victory with at least one Hoard in play. Give the player that many Golds
    gold_pile = game.piles.find_by_card_type("BasicCards::Gold")
        
    game.histories.create!(:event => "#{ply.name} gained #{num_hoards} Gold#{'s' if num_hoards > 1} from #{readable_name}.", 
                          :css_class => "player#{ply.seat} card_gain")
    
    num_hoards.times do |ix|
      ply.queue(parent_act, :gain, :pile => gold_pile.id)      
    end       
  end
end