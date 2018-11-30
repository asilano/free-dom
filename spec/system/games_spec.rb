require 'rails_helper'

RSpec.describe 'Games' do
  describe 'index' do
    it 'shows login buttons if not authd' do
      visit games_path
      expect(page).to have_link('Register')
      expect(page).to have_link('Sign in')
    end
  end
end
