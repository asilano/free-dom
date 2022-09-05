require 'rails_helper'
require 'random_namer'

RSpec.describe 'Games' do
  describe 'index' do
    it 'shows login buttons if not authd' do
      visit games_path
      expect(page).to have_link('Register')
      expect(page).to have_link('Sign in')
    end

    it 'lists games if authd' do
      # Create two games
      games = [
        FactoryBot.create(:game),
        FactoryBot.create(:game, name: nil)
      ]

      # Create and login as a user
      user = FactoryBot.create(:user)
      login_as(user)

      visit games_path
      expect(page).to have_css('#games-list')
      expect(page).to have_css('#games-list table td.name-column .game-id', text: games[0].id)
      expect(page).to have_css('#games-list table td.name-column .game-name', text: games[0].name)
      expect(page).to have_css('#games-list table td.name-column .game-id', text: games[1].id)
    end
  end

  describe 'create' do
    it 'redirects to sign in page if not authd' do
      visit new_game_path
      expect(current_path).to eql(new_user_session_path)
    end

    describe 'when authd' do
      let(:user) { FactoryBot.create(:user) }
      before :each do
        login_as(user)
      end

      it 'creates a game with a name' do
        visit new_game_path
        fill_in 'Name', with: 'My game'
        click_button 'Create Game'

        expect(current_path).to eql(game_path(Game.last))
        visit games_path
        expect(page).to have_css('td.name-column .game-name', text: 'My game')
      end

      it 'creates a game with no name' do
        visit new_game_path
        expect(page).to have_content('A name can help make a game memorable, but isn\'t required')
        click_button 'Create Game'

        expect(current_path).to eql(game_path(Game.last))
        visit games_path
        expect(page).to have_css('td.name-column .game-id', text: Game.last.id)
        expect(page).to have_css('td.name-column .game-name', text: '')
      end

      it 'creates a game with a random name', js: true do
        stub_const('RandomNamer::ADJECTIVES', %w[awful rambunctious])
        expect(RandomNamer::ADJECTIVES).to receive(:sample).and_return 'rambunctious'
        stub_const('RandomNamer::NOUNS', %w[Chimpanzee Princess])
        expect(RandomNamer::NOUNS).to receive(:sample).and_return 'Princess'

        visit new_game_path
        expect(page).to have_content('Want inspiration for a game name? Here\'s a suggestion you can click: Rambunctious Princess')
        page.find('.random-name').click
        click_button 'Create Game'
        visit games_path
        expect(page).to have_css('td.name-column .game-name', text: 'Rambunctious Princess')
      end

      it 'respins the random name', js: true do
        stub_const('RandomNamer::ADJECTIVES', %w[awful rambunctious])
        expect(RandomNamer::ADJECTIVES).to receive(:sample).and_return('rambunctious', 'awful')
        stub_const('RandomNamer::NOUNS', %w[Chimpanzee Princess])
        expect(RandomNamer::NOUNS).to receive(:sample).and_return('Princess', 'Chimpanzee')

        visit new_game_path
        expect(page).to have_content('Want inspiration for a game name? Here\'s a suggestion you can click: Rambunctious Princess')
        page.find('.random-regenerate').click
        expect(page).to have_content('Want inspiration for a game name? Here\'s a suggestion you can click: Awful Chimpanzee')
        page.find('.random-name').click
        click_button 'Create Game'
        visit games_path
        expect(page).to have_css('td.name-column .game-name', text: 'Awful Chimpanzee')
        expect(page).to_not have_css('td.name-column .game-name', text: 'Rambunctious Princess')
      end

      it 'adds me to a game I create' do
        visit new_game_path
        click_button 'Create Game'

        game = Game.last
        expect(game.users.to_a).to eql [user]
      end

      it 'lets me join a game' do
        game = FactoryBot.create(:game_with_one_player)
        expect(game.users).to_not include user
        visit games_path
        click_button 'Join'
        expect(current_path).to eql(game_path(game))
        expect(game.reload.users.to_a).to include user
      end

      it 'lets me join a game from its show page' do
        game = FactoryBot.create(:game_with_two_players)
        expect(game.users).to_not include user
        visit game_path(game)
        click_button 'Join'
        expect(current_path).to eql(game_path(game))
        expect(game.reload.users.to_a).to include user
      end

      it "lists games separately whether I'm in them" do
        you = FactoryBot.create(:user)
        mine = FactoryBot.create(:game_with_kingdom, name: 'Mine')
        FactoryBot.create(:journal, game: mine, user: user, type: GameEngine::AddPlayerJournal)
        ours = FactoryBot.create(:game_with_kingdom, name: 'Ours')
        [user, you].each { |u| FactoryBot.create(:journal, game: ours, user: u, type: GameEngine::AddPlayerJournal) }
        yours = FactoryBot.create(:game_with_kingdom, name: 'Yours')
        FactoryBot.create(:journal, game: yours, user: you, type: GameEngine::AddPlayerJournal)

        visit games_path
        expect(page).to have_css('.game-list-section', text: 'My games')
        expect(page).to have_css('.game-list-section', text: 'Open games')

        within('.game-list-section', text: 'My games') do
          expect(page).to have_css('td.name-column .game-name', text: 'Mine')
          expect(page).to have_css('td.name-column .game-name', text: 'Ours')
          expect(page).to_not have_css('td.name-column .game-name', text: 'Yours')
        end
        within('.game-list-section', text: 'Open games') do
          expect(page).to_not have_css('td.name-column .game-name', text: 'Mine')
          expect(page).to_not have_css('td.name-column .game-name', text: 'Ours')
          expect(page).to have_css('td.name-column .game-name', text: 'Yours')
        end
      end
    end
  end

  describe 'destroy' do
    let(:game) { FactoryBot.build(:game_with_kingdom, name: 'Game for deletion') }
    before :each do
      game.save
    end

    it 'redirects to sign in page if not authd' do
      page.driver.submit :delete, game_path(game), {}
      expect(current_path).to eql(new_user_session_path)
    end

    describe 'when authd' do
      let(:user) { FactoryBot.create(:user) }
      before :each do
        login_as(user)
      end

      it 'deletes the game' do
        visit games_path
        expect(page).to have_css('td.name-column .game-name', text: game.name)
        click_button 'Destroy'
        expect(current_path).to eql(games_path)
        expect(page).to_not have_css('td.name-column .game-name', text: game.name)
      end
    end
  end
end
