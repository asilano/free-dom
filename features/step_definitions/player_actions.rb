# Matches
#   I gain Copper
#   Bob gains Copper, Silver
When(/^(.*) gain(?:s)? (.*)/) do |name, kinds|
  name = "Alan" if name == "I"
  
  kinds.split(/,\s+/).each do |kind|
    params = {}
    params[:pile] = @game.piles.where(:card_type => CARD_TYPES[kind].to_s)[0].id
    pa = @game.pending_actions.where(:parent_id => nil)[0]
    params[:parent_act] = pa.id
    @players[name].do_gain(params)
  end
  
  @game.process_actions
  
  # Need the test to tell us what card movements are expected; especially since Watchtower etc can step in.
  @skip_card_checking = 1 if @skip_card_checking == 0
end

# Matches
#   my next turn starts
#   Bob's next turn starts
When(/^(\w*)(?:'s)? next turn starts$/) do |name|           
  name = "Alan" if name == "my"
  # Each player passes until name's next turn
  # Assumes we're in either an Action or a Buy phase
  # May also assume treasure-playing is automatic (i.e. no Venture, Mint, Grand Market etc)
  
  current_name = @game.current_turn_player.name
  player_hand = @hand_contents[current_name].join(", ") 
  player_hand = "nothing" if player_hand == ""
  if @game.current_turn_player.active_actions[0].expected_action =~ /play_action/
    steps "When #{current_name} stops playing actions
      And the game checks actions"
  end
  assert_match /buy/, @game.current_turn_player.active_actions[0].expected_action
  
  # Upon stopping buying, expect to have discarded everything from play
  @discard_contents[current_name].concat @play_contents[current_name]
  @play_contents[current_name] = []
  steps "When #{current_name} stops buying cards
      And the game checks actions
      Then #{current_name} should have discarded #{player_hand}
      And #{current_name} should have drawn 5 cards"
  
  # Now if we're not at the desired player's turn, do the same again until we are
  loops=0
  while @game.current_turn_player.name != name 
    this_name = @game.current_turn_player.name
    player_hand = @hand_contents[this_name].join(", ")
    player_hand = "nothing" if player_hand == ""
    steps "Then it should be #{this_name}'s Play Action phase
      When #{this_name} stops playing actions
      And the game checks actions
      And #{this_name} stops buying cards
      And the game checks actions
      Then #{this_name} should have discarded #{player_hand}
      And #{this_name} should have drawn 5 cards"
    # Avoid infinite loops if the name doesn't exist
    loops += 1
    if loops>6
      break
    end
  end
  steps "When the game checks actions
    Then it should be #{name}'s Play Action phase"
end       