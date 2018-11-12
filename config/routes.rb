Rails.application.routes.draw do
  get 'welcome/index'

  devise_for :users
  resources :users, except: :create

  post 'create_user' => 'users#create', as: :create_user   

  root to: 'welcome#index'
end