# City (Action - $5) - Draw 1 card, +2 Actions. If there are one or more empty Supply piles, +1 Card. If there are two or more, +1 Cash and +1 Buy

class Prosperity::City < Card
  action
  costs 5
  card_text "Action (Cost: 5) - Draw 1 card, +2 Actions. If there are one or more empty Supply piles, draw another card. If there are two or more, +1 Cash and +1 Buy."
  
  def play(parent_act)
    super
    
    # Nice, straightforard action. First, count the empty piles
    empty = game.piles.select {|p| p.cards.empty?}.length
    
    game.histories.create!(:event => "There #{empty == 1 ? 'is' : 'are'} #{empty == 0 ? 'no' : empty} empty #{empty == 1 ? 'pile' : 'piles'}.",
                          :css_class => "player#{player.seat}")
    
    player.draw_cards(empty >= 1 ? 2 : 1)
    player.add_actions(2, parent_act)
    
    if empty >= 2
      player.add_buys(1, parent_act)
      player.cash += 1
      player.save!
    end
    
    "OK"
  end
end