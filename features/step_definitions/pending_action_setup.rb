Given(/it is (.*?)(?:'s)? (.*) phase/) do |name, phase|
  name = 'Alan' if name == 'my'
  player = @players[name]
  @game.pending_actions.destroy_all
  player.start_turn
  
  case phase
  when "Play Action"
  when "Play Treasure"
    # Destroy the leaf "Play Action" action
    player.active_actions[0].destroy
    player.active_actions(true)
  when "Buy"
    # Destroy the leaf "Play Action" and "Play treasures" actions
    # By destroying them, the treasures won't be auto-played
    player.active_actions[0].destroy    
    player.active_actions(true)
    @game.active_actions(true)
    @game.active_actions[0].destroy    
    player.active_actions(true)
    @game.active_actions(true)
  else
    flunk "Unexpected phase '#{phase}'"
  end  
    
end