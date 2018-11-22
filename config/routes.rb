Rails.application.routes.draw do
 
  get 'stock_capture/index'
  get 'welcome/index'

  devise_for :users

  authenticate :user do
    resources :stock_captures
    resources :stock_lists do
      resources :stock_tickers
      resources :stock_list_users
    end

    resources :users, except: :create
    match '/users',   to: 'users#index',   via: 'get'
    match '/stock_lists/:id/chart',   to: 'stock_lists#chart',   via: 'get'
    match '/stock_values',   to: 'stock_values#index',   via: 'get'
    post 'create_user' => 'users#create', as: :create_user
    post 'run_job' => 'stock_values#run', as: :run_job
    post 'pause_job' => 'stock_values#pause', as: :pause_job
    post 'resume_job' => 'stock_values#resume', as: :resume_job
  end

  root to: 'stock_lists#index'
end