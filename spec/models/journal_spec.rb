require 'rails_helper'

RSpec.describe Journal, type: :model do
  it 'should be valid when ok' do
    journal = FactoryBot.build(:journal)
    expect(journal).to be_valid
  end

  it 'should mark a bad ChooseKingdomJournal as invalid' do
    journal = FactoryBot.build(:kingdom_journal)
    journal.params['card_list'][0] = journal.params['card_list'][1]
    expect(journal).to_not be_valid
  end
end
