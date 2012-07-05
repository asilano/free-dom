Then /the #{SingleCard} pile should cost (\d+)/ do |kind, cost|
  pile = @game.piles.find(:first, :conditions => {:card_type => CARD_TYPES[kind]})
  assert_equal cost.to_i, pile.cost
end
