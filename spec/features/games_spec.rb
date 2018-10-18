require 'rails_helper'

RSpec.describe 'Games', type: :feature do
  describe 'index' do
    it 'enforces login' do
      visit games_path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('You need to sign in or sign up before continuing')
    end
  end
end
