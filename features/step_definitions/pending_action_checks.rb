Then(/it should be (.*?)(?:'s)? (.*) phase/) do |name, phase|
  name = 'Alan' if name == 'my'
  exp_action = case phase
    when "Play Action"
      "play_action"
    when "Play Treasure"
      "player_play_treasures;player=#{@players[name].id}"
    when "Buy"
      "buy"
    end
    
  assert_not_nil exp_action, "Unknown phase '#{phase}'"
    
  actions = @game.active_actions(true).map(&:expected_action) + @players[name].active_actions(true).map(&:expected_action)
  assert_contains(actions, Regexp.new(exp_action))
end

Then(/(.*) should need to (.*)/) do |name, action|
  name = "Alan" if name == "I"
  actions = @players[name].active_actions.map(&:text)
  assert_contains(actions, Regexp.new(action, Regexp::IGNORECASE))
end

Then(/(.*) should not need to act/) do |name|
  name = "Alan" if name == "I"
  assert_empty @players[name].active_actions
end