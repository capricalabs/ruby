Firmhugger::Application.routes.draw do
  root :to => 'pages#index'
  
  #...omitted...

  devise_for :company_admins, :controllers => {
    :registrations => 'company_admins/registrations',
    :confirmations => 'company_admins/confirmations'
  }

  resources :companies, :except => :destroy do
    match 'hug', :controller => 'hugs', :action => 'create', :via => 'post'
    match 'hug', :controller => 'hugs', :action => 'destroy', :via => 'delete'
    get 'hugs_badge', 'huggers'
    collection { get 'autocomplete', 'livesearch' }
    resources :comments, :only => :create
  end
  resources :slideshow_pictures, :only => "create"
  resources :maps, :only => "index"

  get '/profile', :controller => :company_profiles, :action => :edit
  match '/profile', :controller => :company_profiles, :action => :update, :via => :put
  
  #...omitted...
    
  match "*a", :to => "application#render_not_found"
end