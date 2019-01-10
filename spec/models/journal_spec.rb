require 'rails_helper'

RSpec.describe Journal, type: :model do
  it 'should be valid when ok' do
    journal = FactoryBot.build(:journal)
    expect(journal).to be_valid
  end
end
