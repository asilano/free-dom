require 'rails_helper'

RSpec.describe GameEngine, type: :model do
  let(:game) { FactoryBot.build(:game) }
  before(:each) { game.save }
  it 'should be accessible through parent game' do
    game.process
    expect(game.game_state).to be_a(GameEngine::GameState)
  end

  it 'should ask for kingdom choice' do
    game.process
    expect(game.questions).to have(1).item
    expect(game.questions.first).to be_a(GameEngine::ChooseKingdomJournal::Template::Question)
    expect(game.questions.first.text(game.game_state)).to eq 'Choose a Kingdom'
  end

  it 'should ask for players' do
    game = FactoryBot.create(:game_with_kingdom)
    game.process
    expect(game.questions).to have(1).item
    expect(game.questions.first).to be_a(GameEngine::StartGameJournal::Template::Question)
    expect(game.questions.first.text(game.game_state)).to eq 'Wait for more players'
  end

  it 'should ask for game-start if two players exist' do
    game = FactoryBot.create(:game_with_two_players)
    game.process
    expect(game.questions).to have(1).item
    expect(game.questions.first).to be_a(GameEngine::StartGameJournal::Template::Question)
    expect(game.questions.first.text(game.game_state)).to eq 'Wait for more players or Start the game'
  end

  it 'should process game-start' do
    game = FactoryBot.create(:started_game_with_two_players)
    game.process

    # Players should have 7 Coppers and 3 Estates, 5 each in deck and hand
    game.game_state.players.each do |player|
      expect(player.cards.map(&:readable_name)).to match_array(['Estate'] * 3 + ['Copper'] * 7)
      expect(player.hand_cards.count).to eq 5
      expect(player.deck_cards.count).to eq 5
    end
  end

  it 'should log to discord' do
    game = FactoryBot.create(:started_game_with_two_players, discord_webhook: 'https://my.discord.webhook')
    usernames = game.users.map(&:name).sort

    webhooks_client_klass = class_double('Discordrb::Webhooks::Client').as_stubbed_const
    webhooks_client = instance_double('Discordrb::Webhooks::Client')
    builder = Struct.new(:content, :username, :avatar_url).new

    expect(webhooks_client_klass).to receive(:new).with({url: 'https://my.discord.webhook'}).exactly(5).times.and_return(webhooks_client)
    expect(webhooks_client).to receive(:execute).exactly(5).times.and_yield(builder)
    expect(builder).to receive(:content=).with('Artisan, Bandit, Bureaucrat, Cellar, Chapel, Council Room, Festival, Gardens, Harbinger, Laboratory chosen for the kingdom.')
    expect(builder).to receive(:content=).with("#{usernames[0]} joined the game.")
    expect(builder).to receive(:content=).with("#{usernames[1]} joined the game.")
    expect(builder).to receive(:content=).with("#{usernames[0]} started the game.\n - #{usernames[0]} will play 1st.\n - #{usernames[1]} will play 2nd.\n - #{usernames[0]} started turn 1.1.")
    expect(builder).to receive(:content=).with("#{usernames[0]} to act.")
    expect(builder).to receive(:username=).exactly(5).times.with('FreeDom Server')
    expect(builder).to receive(:avatar_url=).exactly(5).times.with("http://localhost:3000/discord-avatar.png")

    game.process
    game.notify_discord
  end

  # it 'should not take too long' do
  #   game = FactoryBot.create(:started_game_with_two_players)

  #   game.users.cycle(1000) do |u|
  #     FactoryBot.create(:journal,
  #                       game: game,
  #                       user: u,
  #                       type: GameEngine::PlayActionJournal,
  #                       params: { 'choice' => 'none' } )
  #   end

  #   puts Time.current
  #   game.process
  #   puts Time.current
  # end
end
