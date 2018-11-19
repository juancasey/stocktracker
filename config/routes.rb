Rails.application.routes.draw do
 
  get 'welcome/index'

  devise_for :users
  resources :users, except: :create
  match '/users',   to: 'users#index',   via: 'get'

  authenticate :user do
    resources :stock_lists do
      resources :stock_tickers
      resources :stock_list_users
    end    
  end
  match '/stock_values',   to: 'stock_values#index',   via: 'get'

  post 'create_user' => 'users#create', as: :create_user
  post 'run_job' => 'stock_values#run', as: :run_job

  root to: 'stock_lists#index'
end