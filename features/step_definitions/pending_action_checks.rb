Then /it should be my (.*) phase/ do |phase|
  exp_action = case phase
    when "Play Treasure"
      "player_play_treasures;player=#{@me.id}"
    when "Buy"
      "buy"
    end
    
  assert_not_nil exp_action, "Unknown phase '#{phase}'"
    
  actions = @game.active_actions.map(&:expected_action) + @me.active_actions.map(&:expected_action)
  assert_contains(actions, Regexp.new(exp_action))
  
  Rails.logger.info("Checked phase")
end