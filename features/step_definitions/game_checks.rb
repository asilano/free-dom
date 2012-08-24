Then /the game should have ended/ do
  assert_equal "ended", @game.state
end

Then /the game fact "(.*)" should be (.*)/ do |key, value|
  assert_equal value, @game.reload.facts[key.gsub(/\s/, '_').to_sym].to_s
end
