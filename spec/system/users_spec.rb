require 'rails_helper'

RSpec.feature "Users" do
  include ActiveJob::TestHelper

  def sign_up(discord_uid: false)
    visit new_user_registration_path
    fill_in 'Email', with: 'me@example.com'
    fill_in 'Password (', with: 's3cretc0de'
    fill_in 'Password confirmation', with: 's3cretc0de'
    fill_in 'Name', with: 'James Smith'
    fill_in('Discord ID', with: 1357924680) if discord_uid
    check 'Contact me'
    click_button 'Sign up'
  end

  describe 'registrations' do
    it 'should allow sign-up' do
      expect { sign_up }.to change { User.count }.by(1)

      user = User.last
      expect(user.email).to eq 'me@example.com'
      expect(user.name).to eq 'James Smith'
      expect(user.contact_me).to be true
    end

    it 'should allow updates' do
      user = FactoryBot.create(:user)
      login_as(user)

      visit edit_user_registration_path(user)
      fill_in 'Name', with: 'James Smith'
      check 'Contact me'
      fill_in 'Current password', with: user.password
      click_on 'Update'

      user.reload
      expect(user.name).to eq 'James Smith'
      expect(user.contact_me).to be true
    end

    it 'should send a registration and new-user emails on sign-up' do
      ActionMailer::Base.deliveries.clear
      expect { perform_enqueued_jobs { sign_up } }.to change { ActionMailer::Base.deliveries.count }.by(2)

      mail = ActionMailer::Base.deliveries[0]
      expect(mail.subject).to eq 'Welcome to FreeDom!'
      expect(mail.to).to eq ['me@example.com']
      expect(mail.from).to eq ['no-reply@example.com']
      expect(mail.parts.map(&:body).map(&:decoded)).to include(match(/\AHi James Smith,$/))
      expect(mail.parts.map(&:body).map(&:decoded)).to include(match(/Welcome to FreeDom!/))

      mail = ActionMailer::Base.deliveries[1]
      expect(mail.subject).to eq 'New user at FreeDom!'
      expect(mail.to).to eq ['dominion.app@gmail.com']
      expect(mail.from).to eq ['no-reply@example.com']
      expect(mail.body.decoded).to match /A new user, going by the name of James Smith and using the email address me@example.com, just registered on FreeDom./
    end

    it 'should reject invalid sign-up' do
      visit new_user_registration_path
      expect { click_button 'Sign up' }.not_to change { User.count }
    end

    it 'should not email on invalid sign-up' do
      visit new_user_registration_path
      expect { perform_enqueued_jobs { click_button 'Sign up' } }.not_to change { ActionMailer::Base.deliveries.count }
    end

    it 'should accept and persist Discord UID on create' do
      expect { sign_up(discord_uid: true) }.to change { User.count }.by(1)

      user = User.last
      expect(user.discord_uid).to eq '1357924680'

      visit edit_user_registration_path(user)
      expect(page).to have_css('[name*="discord_uid"][value="1357924680"]')
    end



    it 'should modify and persist Discord UID' do
      user = FactoryBot.create(:user)
      login_as(user)

      visit edit_user_registration_path(user)
      fill_in 'Discord ID', with: '9876543210'
      fill_in 'Current password', with: user.password
      click_on 'Update'

      user.reload
      expect(user.discord_uid).to eq '9876543210'
    end
  end
end
