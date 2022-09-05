require 'rails_helper'

RSpec.describe ApplicationHelper do
  it 'should display a private log to the right user' do
    user = FactoryBot.create(:user)

    log = "{#{user.id}?Private side - shhhh, secret|Public side - you can't see me!}"
    expect(helper.display_event_for_user(log, user)).to eq 'Private side - shhhh, secret'
  end

  it 'should hide a private log from other users' do
    user = FactoryBot.create(:user)
    other_user = FactoryBot.create(:user)

    log = "{#{user.id}?Private side - shhhh, secret|Public side - you can't see me!}"
    expect(helper.display_event_for_user(log, other_user)).to eq "Public side - you can't see me!"
  end
end
