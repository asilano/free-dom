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
  else
    flunk "Unexpected phase '#{phase}'"
  end  
    
end