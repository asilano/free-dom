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
  Rails.logger.info("ENDING TURN of #{current_name}")
  player_hand = @game.current_turn_player.cards.hand(true).map(&:readable_name).join(", ")
  if @game.current_turn_player.active_actions[0].expected_action =~ /play_action/
    step_text = "When #{current_name} stops playing actions
      And the game checks actions"
    steps step_text  
  end
  assert_match /buy/, @game.current_turn_player.active_actions[0].expected_action
  step_text = "When #{current_name} stops buying cards
      And the game checks actions"
  steps step_text
  if player_hand.blank?
    step_text = "Then #{current_name} should have drawn 5 cards"
  else
    step_text = "Then the following 2 steps should happen at once
      Then #{current_name} should have discarded #{player_hand}
      And #{current_name} should have drawn 5 cards"
  end
  steps step_text
  
  # Now if we're not at the desired player's turn, do the same again until we are
  loops=0
  while @game.current_turn_player.name != name 
    this_name = @game.current_turn_player.name
    Rails.logger.info("SKIPPING TURN of #{this_name}")
    player_hand = @game.current_turn_player.cards.hand(true).map(&:readable_name).join(", ")
    step_text = "Then it should be #{this_name}'s Play Action phase
      When #{this_name} stops playing actions
      And the game checks actions
      And #{this_name} stops buying cards
      And the game checks actions"
    steps step_text
    if player_hand.blank?
      step_text = "Then #{this_name} should have drawn 5 cards"
    else
      step_text = "Then the following 2 steps should happen at once
        Then #{this_name} should have discarded #{player_hand}
        And #{this_name} should have drawn 5 cards"
    end
    steps step_text
    # Avoid infinite loops if the name doesn't exist
    loops += 1
    if loops>6
      break
    end
  end
  step_text = "When the game checks actions
    Then dump actions
    And it should be #{name}'s Play Action phase"
  steps step_text
end       