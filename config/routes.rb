Rails.application.routes.draw do
 
  get 'welcome/index'

  devise_for :users
  resources :users, except: :create

  authenticate :user do
    resources :stock_lists do
      resources :stock_tickers
    end
  end
  post 'create_user' => 'users#create', as: :create_user   

  root to: 'welcome#index'
end