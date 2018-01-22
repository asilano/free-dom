Given(/it is (.*?)(?:'s)? (.*) phase/) do |name, phase|
  name = 'Alan' if name == 'my'
  player = @test_players[name]

  @test_game.add_journal(type: 'HackJournals::HackStartTurnJournal', parameters: { player_id: player.id })

  case phase
  when "Play Action"
    # No-op
  when "Play Treasure"
    # Add journal for playing no actions
    @test_game.add_journal(type: 'Player::Journals::PlayActionJournal', player: player, parameters: { nil_action: true })
  when "Buy"
    # Add journals for playing nothing and playing no treasures
    @test_game.add_journal(type: 'Player::Journals::PlayActionJournal', player: player, parameters: { nil_action: true })
    @test_game.add_journal(type: 'Player::Journals::PlayTreasuresJournal', player: player, parameters: { nil_action: true })
  else
    flunk "Unexpected phase '#{phase}'"
  end

end
