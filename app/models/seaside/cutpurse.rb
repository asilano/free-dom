# 12  Cutpurse  Seaside  Action - Attack  $4  +2 Cash, Each other player discards a Copper card (or reveals a hand with no Copper).
class Seaside::Cutpurse < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - +2 Cash. Each other player discards a Copper card (or reveals a hand with no Copper)."
  
  def play(parent_act)
    super

    # Cash
    player.cash += 2
    # You need to do this if you did something like player.cash += 4 directly
    player.save!

    # Now, attack
    attack(parent_act)
  end
  
  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)                    
  end
  
  def attackeffect(params)
    # Effect of the attack succeeding - that is, ask the target to put a copper
    # card on top of their deck.
    target = Player.find(params[:target])
    # source = Player.find(params[:source])
    parent_act = params[:parent_act]

    target_coppers = target.cards.hand(true).of_type("BasicCards::Copper")
           
    if target_coppers.empty?
      # Target is holding no coppers.
      # "Reveal" the player's hand. Since no-one needs to
      # act on the revealed cards, just add a history entry detailing them.
      game.histories.create!(:event => "#{target.name} revealed their hand to the #{readable_name}:.", 
                            :css_class => "player#{target.seat} card_reveal")
      game.histories.create!(:event => "#{target.name} revealed #{target.cards.hand.join(', ')}.", 
                            :css_class => "player#{target.seat} card_reveal")
    else
      # Target is holding at least one Copper. Discard it.
      card = target_coppers[0]
      card.discard
      game.histories.create!(:event => "#{player.name} discarded #{card}.",
                            :css_class => "player#{player.seat} card_discard")
    end    

    return "OK"
  end
  
end

