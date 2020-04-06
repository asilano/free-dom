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
