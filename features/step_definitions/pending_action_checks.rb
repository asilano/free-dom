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
  actions = @players[name].active_actions(true).map(&:text)
  assert_contains(actions, Regexp.new(action, Regexp::IGNORECASE))
end

Then(/(.*) should not need to act/) do |name|
  name = "Alan" if name == "I"
  assert_empty @players[name].active_actions
end

Then(/(.*) should (not )?be able to choose the (.*) piles?/) do |name, negate, kinds|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We want to check the valid options for a pile-based action. 
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:piles]
  flunk "Unimplemented multi-pile controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  acceptable = ctrl[:piles].map.with_index {|valid, ix| @game.piles[ix].card_type.readable_name if valid}.compact
  
  unless negate
    assert_subset kinds.split(/,\s*/), acceptable
  else
    assert_disjoint kinds.split(/,\s*/), acceptable
  end
end