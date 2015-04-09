# Matches
#   I gain Copper
#   Bob gains Copper, Silver
When(/^(\w*?) gain(?:s)? (.*)/) do |name, kinds|
  name = "Alan" if name == "I"

  kinds.split(/,\s+/).each do |kind|
    params = {}
    params[:pile_id] = @test_game.piles.where(:card_type => CARD_TYPES[kind].to_s)[0].id
    pa = @test_game.pending_actions.where(:parent_id => nil)[0]
    params[:parent_act] = pa.id
    @test_players[name].do_gain(params)
  end

  @test_game.process_actions

  # Need the test to tell us what card movements are expected; especially since Watchtower etc can step in.
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Matches
#   my next turn starts
#   Bob's next turn starts
When(/^(\w*)(?:'s)? next turn starts$/) do |name|
  steps "When #{name}'s next turn is about to start
  And the game checks actions
    Then it should be #{name}'s Play Action phase"
end

# Stops just before the check-actions that would trigger turn-start
When(/^(\w*)(?:'s)? next turn is about to start$/) do |name|
  name = "Alan" if name == "my"
  # Each player passes until name's next turn
  # Assumes we're in either an Action or a Buy phase
  # May also assume treasure-playing is automatic (i.e. no Venture, Mint, Grand Market etc)

  current_name = @test_game.current_turn_player.name
  if @test_game.current_turn_player.active_actions[0].expected_action =~ /play_action/
    steps "When #{current_name} stops playing actions
      And the game checks actions"
  end
  if @test_game.current_turn_player.active_actions(true)[0].expected_action =~ /play_treasure/
    steps "When #{current_name} stops playing treasures"
  end
  assert_match /buy/, @test_game.current_turn_player.active_actions(true)[0].expected_action

  # Upon stopping buying, expect to have discarded everything from play
  @discard_contents[current_name].concat @play_contents[current_name]
  @play_contents[current_name] = []
  steps "When #{current_name} stops buying cards
      And the game checks actions
      Then #{current_name} should have ended his turn"

  # Now if we're not at the desired player's turn, do the same again until we are
  loops=0

  while @test_game.current_turn_player.name != name
    this_name = @test_game.current_turn_player.name
    steps "Then it should be #{this_name}'s Play Action phase
      When #{this_name} stops playing actions
      And the game checks actions
      And #{this_name} stops buying cards
      And the game checks actions
      Then #{this_name} should have ended his turn"
    # Avoid infinite loops if the name doesn't exist
    loops += 1
    if loops>6
      break
    end
  end
end

# Stops just before the check-actions that would trigger turn-end
When(/^(\w*)(?:'s)? turn is about to end$/) do |name|
  name = "Alan" if name == "my"

  current_name = @test_game.current_turn_player.name
  assert_equal name, current_name
  if @test_game.current_turn_player.active_actions[0].expected_action =~ /play_action/
    steps "When #{current_name} stops playing actions
      And the game checks actions"
  end
  if @test_game.current_turn_player.active_actions(true)[0].expected_action =~ /play_treasure/
    steps "When #{current_name} stops playing treasures"
  end
  assert_match /buy/, @test_game.current_turn_player.active_actions(true)[0].expected_action

  steps "When #{current_name} stops buying cards"
end