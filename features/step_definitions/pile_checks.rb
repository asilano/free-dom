Then /the #{SingleCard} pile should cost (\d+)/ do |kind, cost|
  pile = @test_game.piles.where {card_type == CARD_TYPES[kind].to_s}.first
  assert_equal cost.to_i, pile.cost
end

Then /the "(.*)" state of the #{SingleCard} pile should be (.*)/ do |key, kind, value|
  pile = @test_game.piles.where {card_type == CARD_TYPES[kind].to_s}.first
  assert_equal value, pile.reload.state[key.gsub(/\s/, '_').to_sym].to_s
end

Then /the #{SingleCard} pile should have no "(.*)" state/ do |kind, key|
  pile = @test_game.piles.where {card_type == CARD_TYPES[kind].to_s}.first
  refute_includes pile.reload.state, key.gsub(/\s/, '_').to_sym
end