Rails.application.routes.draw do
  resources :games, except: %i[edit update]
  resources :players, only: :create
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'random_name', to: 'games#random_name'

  # Temporary - so page "works" in production
  root to: 'games#index'
end
