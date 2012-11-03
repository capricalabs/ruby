Mmp::Application.routes.draw do
  devise_for :users
  devise_for :admins
  resources :addresses do
	put 'default', :on => :member
	get 'choose', :on => :collection
  end
  match 'admin/manage/:type(/:action/(/:id))' => 'admin/manage', :as => 'manage'
  match 'admin/manage/:utype/edit/:uid/:type(/:action/(/:id))' => 'admin/manage', :as => 'manage_addresses'
  match 'admin' => 'admin/dashboard#index'
  match 'admin/dashboard(/:action)' => 'admin/dashboard'
  match 'home' => 'public#index'
  match 'phone-specs/:id' => 'public#phone_specs', :as => 'phone_specs'
  match 'warranty-info/:id' => 'public#warranty_info', :as => 'warranty_info'
  match 'how-it-works' => 'public#how_it_works', :as => 'how_it_works'
  match 'contact' => 'public#contact', :as => 'contact'
  match 'deals/:id' => 'deals#show', :as => 'deal'
  match 'deals' => 'deals#index', :as => 'deals'
  match 'checkout(/:action)' => 'checkout', :as => 'checkout'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'public#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
