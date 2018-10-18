require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'should be valid when ok' do
    game = build(:game)
    expect(game).to be_valid
  end

  it 'should require a name' do
    game = build(:game, name: nil)
    expect(game).to_not be_valid
    expect(game.errors).to be_added(:name, :blank)
  end
end
