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
    expect(game.question).to be_a(GameEngine::ChooseKingdomJournal::Template::Question)
    expect(game.question.text game.game_state).to eq 'Choose a Kingdom'
  end

  it 'should ask for players' do
    game = FactoryBot.create(:game_with_kingdom)
    game.process
    expect(game.question).to be_a(GameEngine::StartGameJournal::Template::Question)
    expect(game.question.text game.game_state).to eq 'Wait for more players'
  end

  it 'should ask for game-start if two players exist' do
    game = FactoryBot.create(:game_with_two_players)
    game.process
    expect(game.question).to be_a(GameEngine::StartGameJournal::Template::Question)
    expect(game.question.text game.game_state).to eq 'Wait for more players or Start the game'
  end
end
