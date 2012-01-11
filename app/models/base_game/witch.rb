class BaseGame::Witch < Card
  costs 5
  action :attack => true, 
         :order_relevant => lambda { |params|
           curses_pile = game.piles.find_by_card_type("BasicCards::Curse")
           curses_pile.cards.length < game.players.length - 1}
  card_text "Action (Attack; cost: 5) - Draw 2 cards. Each other player gains a Curse card."
    
  def play(parent_act)
    super
    
    # First, draw two cards
    player.draw_cards(2)
    
    # Then conduct the attack
    attack(parent_act)
    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)    
    determine_react_controls(player, controls, substep, params)
  end   
  
  def attackeffect(params)
    # Effect of the attack succeeding - that is, grant a Curse if any are left.
    ply = Player.find(params[:target])
    parent_act = params[:parent_act]
    
    curses_pile = game.piles.find_by_card_type("BasicCards::Curse")
    if not curses_pile.empty?
      game.histories.create!(:event => "#{ply.name} gained a Curse.",
                            :css_class => "player#{ply.seat} card_gain")
      ply.queue(parent_act, :gain, :pile => curses_pile.id)       
    else
      game.histories.create!(:event => "#{ply.name} couldn't gain a Curse - none left.", 
                            :css_class => "player#{ply.seat}")
    end
    
    return "OK"
  end 
end
