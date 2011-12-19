ActionController::Routing::Routes.draw do |map|
  map.login 'users/login', :controller => 'users', :action => 'login'
  map.logout 'users/logout', :controller => 'users', :action => 'logout'
  map.settings 'users/settings', :method => :get, :controller => 'users', :action => 'edit'
  map.password_reset 'users/password_reset', :controller => 'users', :action => 'password_reset'
  map.resources :users, :except => [:edit]   
  
  map.clear_player 'dominion/clear_player', :controller => 'games', :action => 'clear_player'
  map.card_text 'dominion/card_text', :controller => 'games', :action => 'card_text'
  map.resources :games, :as => :dominion,
                        :member => {:join => :post,
                                    :watch => :get,
                                    :play => :get,
                                    :start_game => :post,
                                    :update_game => :get,
                                    :play_action => :post,
                                    :play_treasure => :post,
                                    :buy => :post,
                                    :end_turn => :post,
                                    :resolve => :post,
                                    :check_change => :get,
                                    :update_player_settings => :post,
                                    :speak => :post}
  map.connect 'dominion/:action', :controller => 'games'
  
  map.about 'about', :controller => 'users', :action => 'about'
  map.contact 'contact', :controller => 'users', :action => 'contact'

  # Email interface
  map.pbem 'pbem', :controller => 'pbem', :action => 'handle' #,:method => :post
  map.nop 'nop', :controller => 'pbem', :action => 'nop' #,:method => :post
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "games", :action => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
