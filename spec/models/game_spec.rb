require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'should be valid when ok' do
    game = build(:game)
    expect(game).to be_valid
  end

  it 'should not require a name' do
    game = build(:game, name: nil)
    expect(game).to be_valid
  end
end
