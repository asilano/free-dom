Given(/it is (.*?)(?:'s)? (.*) phase/) do |name, phase|
  name = 'Alan' if name == 'my'
  hack_journal = "Hack: #{name} start turn"
  @test_game.add_journal(event: hack_journal)
  @test_game.process_journals

  case phase
  when "Play Action"
    # No-op
  when "Play Treasure"
    # Destroy the leaf "Play Action" action
    player.pending_actions.active.first.destroy
    player.pending_actions(true)

    # Make it the BUY turn phase (yes, really)
    @test_game.turn_phase = Game::TurnPhases::BUY
    @test_game.save
  when "Buy"
    # Destroy the leaf "Play Action" and "Play treasures" actions
    # By destroying them, the treasures won't be auto-played
    player.pending_actions.active.first.destroy
    player.pending_actions(true)
    @test_game.pending_actions(true)
    @test_game.pending_actions.active.unowned.first.destroy
    player.pending_actions(true)
    @test_game.pending_actions(true)

    # Make it the BUY turn phase
    @test_game.turn_phase = Game::TurnPhases::BUY
    @test_game.save
  else
    flunk "Unexpected phase '#{phase}'"
  end

end
