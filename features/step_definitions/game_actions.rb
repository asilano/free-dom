When /the game checks actions/ do
  @test_game.process_actions

  # We usually expect treasures to have been played, or cards to have been gained
  @skip_card_checking = 1 if @skip_card_checking == 0
end

When /the game ends/ do
  @test_game.end_game
end