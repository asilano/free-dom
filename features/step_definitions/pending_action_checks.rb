# Check the pending action is correct for a given ("stack-empty") phase of the game.
# Checks for Play Action, Play Treasure and Buy phases
Then(/it should be (.*?)(?:'s)? (.*) phase/) do |name, phase|
  name = 'Alan' if name == 'my'
  exp_text = case phase
    when "Play Action"
      'Play an action'
    when "Play Treasure"
      /(play_treasure|player_play_treasures;player=#{@test_players[name].id})/
    when "Buy"
      /buy/
    end

  assert_not_nil exp_text, "Unknown phase '#{phase}'"

  assert_contains(@test_players[name].questions.map(&:text), exp_text, "Questions didn't contain #{exp_text}")
end

# Check for the readable text of a pending action
Then(/(.*) should (not )?need to (?!act)(.*)/) do |name, negate, action|
  name = "Alan" if name == "I"
  actions = @test_players[name].pending_actions(true).active.map(&:text)

  if negate
    assert_not_contains(actions, /^#{action}$/i)
  else
    assert_contains(actions, /^#{action}$/i)
  end
end

# Check the specified player is not currently required to do anything
Then(/(.*) should not need to act/) do |name|
  name = "Alan" if name == "I"
  assert_empty @test_players[name].pending_actions(true).active
end

# Verify that the stated cards in hand are (not) choosable
#
# Matches:
#   I should be able to choose Silver, Gold, Village in my hand
#   Bob should not be able to choose Province in his hand
Then(/(.*) should (not )?be able to choose #{CardListNoRep} in (?:my|his) hand/) do |name, negate, kinds|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We want to check the valid options for a hand-based action.
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:hand]
  flunk "No controls found in #{name}'s hand" if controls.length == 0
  flunk "Too many controls in #{name}'s hand" unless controls.length == 1

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
Then(/^(.*) should (not )?be able to choose a nil action (?:named (.*) )?in (?:my|his) hand$/) do |name, negate, nil_name|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We want to check the valid options for a hand-based action.
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:hand]
  flunk "Unimplemented multi-hand controls in testbed" unless controls.length == 1

  ctrl = controls[0]

  if negate
    if nil_name
      assert_not_contains Array(ctrl[:nil_action]), nil_name
    else
      refute Array(ctrl[:nil_action]).any?
    end
  else
    if nil_name
      assert_contains Array(ctrl[:nil_action]), nil_name
    else
      assert Array(ctrl[:nil_action]).any?
    end
  end
end

# Verify that the stated cards in play are (not) choosable
#
# Matches:
#   I should be able to choose Silver, Gold, Village in play
#   Bob should not be able to choose Province in play
Then(/(.*) should (not )?be able to choose #{CardListNoRep} in play/) do |name, negate, kinds|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We want to check the valid options for a play-based action.
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:play]
  flunk "No controls found in #{name}'s in-play" if controls.length == 0
  flunk "Too many controls in #{name}'s in-play" unless controls.length == 1

  ctrl = controls[0]
  acceptable = ctrl[:cards].map.with_index {|valid, ix| player.cards.in_play[ix].readable_name if valid}.compact

  unless negate
    assert_subset kinds.split(/,\s*/), acceptable
  else
    assert_disjoint kinds.split(/,\s*/), acceptable
  end
end

# Verify that there is (not) a nil action in play
#
# Matches:
#   I should be able to choose a nil action in play
#   Bob should not be able to choose a nil action in play
Then(/^(.*) should (not )?be able to choose a nil action (?:named (.*) )?in play$/) do |name, negate, nil_name|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We want to check the valid options for a play-based action.
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:play]
  flunk "Unimplemented multi-play controls in testbed" unless controls.length == 1

  ctrl = controls[0]

  if negate
    if nil_name
      assert_not_contains Array(ctrl[:nil_action]), nil_name
    else
      refute Array(ctrl[:nil_action]).any?
    end
  else
    if nil_name
      assert_contains Array(ctrl[:nil_action]), nil_name
    else
      assert Array(ctrl[:nil_action]).any?
    end
  end
end

# Verify that the stated piles are (not) choosable
#
# Matches:
#   I should be able to choose the Silver, Gold, Village piles
#   Bob should not be able to choose the Province pile
Then(/(.*) should (not )?be able to choose the (.*) piles?$/) do |name, negate, kinds|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We want to check the valid options for a pile-based action.
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:piles]
  flunk "Unimplemented multi-pile controls in testbed" unless controls.length == 1

  ctrl = controls[0]
  acceptable = ctrl[:piles].map.with_index {|valid, ix| @test_game.piles[ix].card_class.readable_name if valid}.compact

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
  player = @test_players[name]

  # We want to check the valid options for a pile-based action.
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:piles]

  controls.select! {|c| c[:text] =~ /^#{Regexp.escape(label)}$/i}
  flunk "Multiple pile controls with same button text" unless controls.length == 1
  ctrl = controls[0]
  acceptable = ctrl[:piles].map.with_index {|valid, ix| @test_game.piles[ix].card_class.readable_name if valid}.compact

  unless negate
    assert_subset kinds.split(/,\s*/), acceptable
  else
    assert_disjoint kinds.split(/,\s*/), acceptable
  end
end

# Verify that there is (not) a nil action on piles
#
# Matches:
#   I should be able to choose a nil action on piles
#   Bob should not be able to choose a nil action on piles
Then(/^(.*) should (not )?be able to choose a nil action (?:named (.*) )?on piles$/) do |name, negate, nil_name|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We want to check the valid options for a play-based action.
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:piles]
  flunk "Unimplemented multi-play controls in testbed" unless controls.length == 1

  ctrl = controls[0]

  if negate
    if nil_name
      assert_not_contains Array(ctrl[:nil_action]), nil_name
    else
      refute Array(ctrl[:nil_action]).any?
    end
  else
    if nil_name
      assert_contains Array(ctrl[:nil_action]), nil_name
    else
      assert Array(ctrl[:nil_action]).any?
    end
  end
end

# Verify that a dropdown control has the stated options
#
# Matches:
#   I should be able to choose exactly 0, 1, 2, 3 from the dropdown
#   Bob should be able to choose 1, 2 from the dropdown // non-exact match
Then /(.*) should be able to choose (exactly )?(.*) from the dropdown/ do |name, exact, choices|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We want to check the valid options for a player-based action.
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:player]
  flunk "Unimplemented multi-dropdown controls in testbed" unless controls.length == 1
  flunk "Expected dropdown control" unless controls[0][:type] == :dropdown

  ctrl = controls[0]

  if exact
    assert_same_elements choices.split(/,\s*/), ctrl[:choices].map(&:first)
  else
    assert_contains ctrl[:choices].map(&:first), choices.split(/,\s*/)
  end
end

# Verify that an option-only control has the stated option
#
# Matches:
#   I should be able to choose the option Don't discard
#   I should not be able to choose the option Reticulate the splines
Then /(.*) should (not )?be able to choose the option (.*)$/ do |name, negate, choice|
  name = "Alan" if name == "I"
  player = @test_players[name]

  # We want to check the valid options for a pile-based action.
  # These are encoded in the control that that action produces.
  all_controls = player.determine_controls
  controls = all_controls[:player]
  flunk "No options controls found for #{name}" if controls.length == 0
  flunk "Too many options controls for #{name}" unless controls.length == 1

  ctrl = controls[0]
  acceptable = ctrl[:options].map {|opt| opt[:text]}

  unless negate
    assert_contains acceptable, choice
  else
    assert_not_contains acceptable, choice
  end
end