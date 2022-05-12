Rails.application.routes.draw do
  resources :journals, only: %i[create destroy]
  resources :games, except: %i[edit] do
    collection do
      post "card_shaped_fields"
    end
  end
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'random_name', to: 'games#random_name'

  # Temporary - so page "works" in production
  root to: 'games#index'
end
