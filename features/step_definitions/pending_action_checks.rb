# Check the pending action is correct for a given ("stack-empty") phase of the game.
# Checks for Play Action, Play Treasure and Buy phases
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

# Check for the readable text of a pending action
Then(/(.*) should need to (.*)/) do |name, action|
  name = "Alan" if name == "I"
  actions = @players[name].active_actions(true).map(&:text)
  assert_contains(actions, Regexp.new(action, Regexp::IGNORECASE))
end

# Check the specified player is not currently required to do anything
Then(/(.*) should not need to act/) do |name|
  name = "Alan" if name == "I"
  assert_empty @players[name].active_actions(true)
end

# Verify that the stated cards in hand are (not) choosable
# 
# Matches:
#   I should be able to choose Silver, Gold, Village in my hand
#   Bob should not be able to choose Province in his hand
Then(/(.*) should (not )?be able to choose #{CardListNoRep} in (?:my|his) hand/) do |name, negate, kinds|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We want to check the valid options for a hand-based action. 
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:hand]
  flunk "Unimplemented multi-hand controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  acceptable = ctrl[:cards].map.with_index {|valid, ix| player.cards.hand[ix].readable_name if valid}.compact
  
  unless negate
    assert_subset kinds.split(/,\s*/), acceptable
  else
    assert_disjoint kinds.split(/,\s*/), acceptable
  end
end

# Verify that there is (not) a nil action in the hand
#
# Matches:
#   I should be able to choose a nil action in my hand
#   Bob should not be able to choose a nil action in his hand
Then /(.*) should (not )?be able to choose a nil action in (?:my|his) hand/ do |name, negate|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We want to check the valid options for a hand-based action. 
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:hand]
  flunk "Unimplemented multi-hand controls in testbed" unless controls.length == 1
  
  ctrl = controls[0]
  
  unless negate
    assert_not_nil ctrl[:nil_action]
  else
    assert_nil ctrl[:nil_action]
  end
end

# Verify that the stated piles are (not) choosable
# 
# Matches:
#   I should be able to choose the Silver, Gold, Village piles
#   Bob should not be able to choose the Province pile
Then(/(.*) should (not )?be able to choose the (.*) piles?$/) do |name, negate, kinds|
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

# Verify that the stated piles are (not) choosable.
# Handles multiple actions present at once, by differentiating on button text
# 
# Matches:
#   I should be able to choose the Silver, Gold, Village piles labelled Give to Bob
Then(/(.*) should (not )?be able to choose the (.*) piles? labelled (.*)$/) do |name, negate, kinds, label|
  name = "Alan" if name == "I"
  player = @players[name]
  
  # We want to check the valid options for a pile-based action. 
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:piles]
  
  controls.select! {|c| c[:text] =~ Regexp.new(Regexp.escape(label), Regexp::IGNORECASE)}
  flunk "Multiple pile controls with same button text" unless controls.length == 1
  ctrl = controls[0]
  acceptable = ctrl[:piles].map.with_index {|valid, ix| @game.piles[ix].card_type.readable_name if valid}.compact
  
  unless negate
    assert_subset kinds.split(/,\s*/), acceptable
  else
    assert_disjoint kinds.split(/,\s*/), acceptable
  end
end