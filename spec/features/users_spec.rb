require 'rails_helper'

RSpec.feature "Users", type: :feature do
  describe 'registrations' do
    it 'should allow sign-up' do
      expect do
        visit new_user_registration_path
        fill_in 'Email', with: 'me@example.com'
        fill_in 'Password (', with: 's3cretc0de'
        fill_in 'Password confirmation', with: 's3cretc0de'
        fill_in 'Name', with: 'James Smith'
        check 'Contact me'
        click_on 'Sign up'
      end.to change { User.count }.by(1)

      user = User.last
      expect(user.email).to eq 'me@example.com'
      expect(user.name).to eq 'James Smith'
      expect(user.contact_me).to be true
    end
  end
end
