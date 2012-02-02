Given /it's my (.*) phase/ do |phase| #'
  @game.pending_actions.destroy_all
  @me.start_turn
  
  case phase
  when "Play Action"
  when "Play Treasure"
    # Destroy the leaf "Play Action" action
    @me.active_actions[0].destroy
  else
    flunk "Unexpected phase '#{phase}'"
  end  
    
end