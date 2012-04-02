Then /(.*) should have (\d+) actions? available/ do |name, actions|
  name = "Alan" if name == "I"
  assert_equal actions.to_i, @players[name].reload.actions
end

Then /(.*) should have (\d+) buys? available/ do |name, buys|
  name = "Alan" if name == "I"
  assert_equal buys.to_i, @players[name].reload.buys
end

Then /(.*) should have (\d+) cash/ do |name, cash|
  name = "Alan" if name == "I"
  assert_equal cash.to_i, @players[name].reload.cash
end

Then(/(.*?)(?:'s)? score should be (-)?(\d+)/) do |name, neg, score|
  name = "Alan" if name == "my"
  exp = score.to_i
  exp = -exp if neg
  assert_equal exp, @players[name].reload.score
end