require "rails_helper"

RSpec.describe SignUpMailer, type: :mailer do
  describe 'welcome' do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { SignUpMailer.with(user: user).welcome }

    it 'renders correctly' do
      expect(mail.subject).to eq 'Welcome to FreeDom!'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@example.com']
      expect(mail.parts.map(&:body).map(&:decoded)).to include(match(/\AHi #{user.name},$/))
      expect(mail.parts.map(&:body).map(&:decoded)).to include(match(/Welcome to FreeDom!/))
    end
  end
end
