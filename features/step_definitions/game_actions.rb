When /the game checks actions/ do
  flunk "deprecated step"
end

When /the game ends/ do
  @test_game.end_game
end