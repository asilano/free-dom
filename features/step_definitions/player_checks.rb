Then /(.*) should have (\d+) actions? available/ do |name, actions|
  name = "Alan" if name == "I"
  assert_equal actions.to_i, @test_players[name].reload.actions
end

Then /(.*) should have (\d+) buys? available/ do |name, buys|
  name = "Alan" if name == "I"
  assert_equal buys.to_i, @test_players[name].reload.buys
end

Then /(.*) should have (\d+) cash/ do |name, cash|
  name = "Alan" if name == "I"
  assert_equal cash.to_i, @test_players[name].reload.cash
end

Then /(.*) should have (\d+) cards in hand/ do |name, cards|
  name = "Alan" if name == "I"
  assert_equal cards.to_i, @test_players[name].cards.hand(true).length
end

Then(/(.*?)(?:'s)? score should be (-)?(\d+)/) do |name, neg, score|
  name = "Alan" if name == "my"
  exp = score.to_i
  exp = -exp if neg
  assert_equal exp, @test_players[name].reload.score
end

Then(/^(.*?)(?:'s)? state (\w*) should be (.*)$/) do |name, prop, expected|
  name = "Alan" if name == "my"

  actual = @test_players[name].state.send(prop.to_sym)
  assert_equal expected, actual.to_s, "Expected player #{name}'s state #{prop} to be #{expected} but it was #{actual.to_s}"
end

Then(/^(.*) should have ended (?:my|his) turn$/) do |name|
  name = "Alan" if name == "I"

  steps "Then #{name} should have discarded his hand
         And #{name} should have discarded his in-play cards
         And #{name} should have drawn 5 cards"
end