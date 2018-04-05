Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Temporary - so page "works" in production
  get '/'                      => "rails/welcome#index"
end
