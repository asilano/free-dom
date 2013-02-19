Then /the #{SingleCard} pile should cost (\d+)/ do |kind, cost|
  pile = @game.piles.find(:first, :conditions => {:card_type => CARD_TYPES[kind]})
  assert_equal cost.to_i, pile.cost
end

Then /the "(.*)" state of the #{SingleCard} pile should be (.*)/ do |key, kind, value|
  pile = @game.piles.find(:first, :conditions => {:card_type => CARD_TYPES[kind]})
  assert_equal value, pile.reload.state[key.gsub(/\s/, '_').to_sym].to_s
end

Then /the #{SingleCard} pile should have no "(.*)" state/ do |kind, key|
  pile = @game.piles.find(:first, :conditions => {:card_type => CARD_TYPES[kind]})
  refute_includes pile.reload.state, key.gsub(/\s/, '_').to_sym
end