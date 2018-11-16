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
  post 'create_user' => 'users#create', as: :create_user

  root to: 'stock_lists#index'
end