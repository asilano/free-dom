require 'rails_helper'

RSpec.describe User, type: :model do
  it 'should be valid when ok' do
    user = build(:user)
    expect(user).to be_valid
  end

  it 'should require a name' do
    user = build(:user, name: nil)
    expect(user).to_not be_valid
    expect(user.errors).to be_added(:name, :blank)
  end
end
