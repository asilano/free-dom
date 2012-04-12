# Bank (Treasure - $7) - When you play this, it's worth 1 Cash per Treasure card you have in play (including this).

class Prosperity::Bank < Card
  treasure :special => true
  costs 7
  card_text "Treasure (cost: 7) - When you play this, it's worth 1 Cash per Treasure card you have in play (including this)."
  
  def play_treasure(parent_act)
    # Get the superclass to move the card
    super
    
    # Now, grant the player cash equal to the number of Treasures they have in play
    cash = player.cards.in_play.select {|c| c.is_treasure?}.count
    player.cash += cash
    player.save!
    
    game.histories.create!(:event => "Bank granted #{player.name} #{cash} cash.",
                          :css_class => "player#{player.seat} play_treasure")
    "OK"
  end
end
