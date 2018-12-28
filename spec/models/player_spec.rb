require 'rails_helper'

RSpec.describe Player, type: :model do
  it 'is valid when ok' do
    player = FactoryBot.build(:player)
    expect(player).to be_valid
  end

  it 'validates both joins' do
    player = FactoryBot.build(:player, game: nil)
    expect(player).to_not be_valid
    player = FactoryBot.build(:player, user: nil)
    expect(player).to_not be_valid
  end
end
