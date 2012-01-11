Dominion::Application.routes.draw do
  match 'users/login', :controller => 'users', :action => 'login', :as => 'login'
  match 'users/logout', :controller => 'users', :action => 'logout', :as => 'logout'
  match 'users/settings', :method => :get, :controller => 'users', :action => 'edit', :as => 'settings'
  match 'users/password_reset', :controller => 'users', :action => 'password_reset', :as => 'password_reset'
  resources :users, :except => [:edit]
  
  match 'dominion/clear_player', :controller => 'games', :action => 'clear_player', :as => 'clear_player'
  match 'dominion/card_text', :controller => 'games', :action => 'card_text', :as => 'card_text'
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
      post :resolve
      get  :check_change
      post :update_player_settings
      post :speak
    end
  end
  match 'dominion/:action', :controller => 'games'
  
  match 'about', :controller => 'users', :action => 'about', :as => 'about'
  match 'contact', :controller => 'users', :action => 'contact', :as => 'contact'

  # Email interface
  match 'pbem', :controller => 'pbem', :action => 'handle' #,:method => :post, :as => 'pbem'
  match 'nop', :controller => 'pbem', :action => 'nop' #,:method => :post, :as => 'nop'
  
  
  root :to => "games#index"

  # See how all your routes lay out with "rake routes"

end
