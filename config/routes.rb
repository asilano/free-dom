Dominion::Application.routes.draw do
  # themes_for_rails
  theme_dir = ThemesForRails.config.themes_routes_dir
  constraints = { :theme => /[\w\.]*/ }

  get "#{theme_dir}/:theme/stylesheets/*asset" => 'themes_for_rails/assets#stylesheets',
    :as => :base_theme_stylesheet, :constraints => constraints
  get "#{theme_dir}/:theme/javascripts/*asset" => 'themes_for_rails/assets#javascripts',
    :as => :base_theme_javascript, :constraints => constraints
  get "#{theme_dir}/:theme/images/*asset" => 'themes_for_rails/assets#images',
    :as => :base_theme_image, :constraints => constraints

  match 'users/login', :controller => 'users', :action => 'login', :as => 'login', via: [:get, :post]
  get 'users/logout', :controller => 'users', :action => 'logout', :as => 'logout'
  get 'users/settings', :method => :get, :controller => 'users', :action => 'edit', :as => 'settings'
  match 'users/password_reset', :controller => 'users', :action => 'password_reset', :as => 'password_reset', via: [:get, :post]
  get 'users/registered', :controller => 'users', :action => 'registered', :as => 'registered'
  resources :users, :except => [:edit]

  get 'dominion/card_text', :controller => 'games', :action => 'card_text', :as => 'card_text'
  resources :dominion, :as => :games, :controller => 'games' do
    member do
      post :join
      get  :watch
      get  :play
      post :start_game
      get  :update_game
      post :play_action
      post :play_treasure
      post :buy
      post :end_turn
      post :choose_sot_card
      post :resolve
      get  :check_change
      post :update_player_settings
      post :speak
      post :perform
      get :process_result
    end
  end
  resources :journals
  #match 'dominion/:action', :controller => 'games'

  get 'about', :controller => 'users', :action => 'about', :as => 'about'
  get 'contact', :controller => 'users', :action => 'contact', :as => 'contact'

  # Email interface
  #match 'pbem', :controller => 'pbem', :action => 'handle' #,:method => :post, :as => 'pbem'
  #match 'nop', :controller => 'pbem', :action => 'nop' #,:method => :post, :as => 'nop'

  # Announcements interface
  resources :announcements, :only => [:new, :create]

  root :to => "games#index"

  # See how all your routes lay out with "rake routes"

end
