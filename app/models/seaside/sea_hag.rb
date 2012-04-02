# 17	Sea Hag	Seaside	Action - Attack	$4	Each other player discards the top card of his deck, then gains a Curse card, putting it on top of his deck.

class Seaside::SeaHag < Card
  costs 4
  action :attack => true, 
         :order_relevant => lambda { |params|           
           curses_pile = game.piles.find_by_card_type("BasicCards::Curse")
           curses_pile.cards.length < game.players.length - 1}
  card_text "Action (Attack; cost: 4) - Each other player discards the top card of his deck, then gains a Curse card, putting it on top of his deck."
  
  def play(parent_act)
    super
    
    attack(parent_act)
    
    return "OK"
  end

  def determine_controls(player, controls, substep, params)    
    determine_react_controls(player, controls, substep, params)
  end   
  
  def attackeffect(params)
    # Effect of the attack succeeding - that is, discard the top card, and 
    # grant a Curse to top of deck if any are left.
    ply = Player.find(params[:target])
    parent_act = params[:parent_act]
    
    if ply.cards.deck(true).empty?
      ply.shuffle_discard_under_deck
    end
    
    if !ply.cards.deck.empty?
      card = ply.cards.deck[0]       
      card.discard
      game.histories.create!(:event => "#{ply.name} discarded #{card.readable_name} from their deck.",
                              :css_class => "player#{ply.seat} card_discard")
    else 
      # No cards in deck. Just create a history
      game.histories.create!(:event => "#{ply.name} couldn't discard as there were no cards in their deck.",
                              :css_class => "player#{ply.seat} card_discard")
    end
    
    curses_pile = game.piles.find_by_card_type("BasicCards::Curse")
    if not curses_pile.empty?
      game.histories.create!(:event => "#{ply.name} gained a Curse to the top of their deck.",
                            :css_class => "player#{ply.seat} card_gain")
      ply.queue(parent_act, :gain, :pile => curses_pile.id, :location => "deck")
    else
      game.histories.create!(:event => "#{ply.name} couldn't gain a Curse - none left.", 
                            :css_class => "player#{ply.seat}")
    end
    
    return "OK"
  end 

end

