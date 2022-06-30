require "rails_helper"

RSpec.describe SignUpMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user) }

  describe 'welcome' do
    let(:mail) { SignUpMailer.with(user: user).welcome }

    it 'renders correctly' do
      expect(mail.subject).to eq 'Welcome to FreeDom!'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@example.com']
      expect(mail.parts.map(&:body).map(&:decoded)).to include(match(/\AHi #{user.name},$/))
      expect(mail.parts.map(&:body).map(&:decoded)).to include(match(/Welcome to FreeDom!/))
    end
  end

  describe 'new_user' do
    let(:mail) { SignUpMailer.with(user: user).new_user }

    it 'renders correctly' do
      expect(mail.subject).to eq 'New user at FreeDom!'
      expect(mail.to).to eq ['no-reply@example.com']
      expect(mail.from).to eq ['no-reply@example.com']
      expect(mail.body.decoded).to match /A new user, going by the name of #{user.name} and using the email address #{user.email}, just registered on FreeDom./
    end
  end
end
