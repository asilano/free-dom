When /the game checks actions/ do
  @game.process_actions
  
  # We usually expect treasures to have been played
  @skip_card_checking = 1
end

When /the game ends/ do
  @game.end_game
end