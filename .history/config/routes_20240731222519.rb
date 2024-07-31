# config/routes.rb
Rails.application.routes.draw do
  root 'pages#home'
  
  devise_for :users
  
  resources :rooms do
    resources :bookings, only: [:new, :create]
    resources :reviews, only: [:create]
  end

  # config/routes.rb
  get 'faq', to: 'pages#faq'

  
  get 'search', to: 'pages#search'
  get 'dashboard', to: 'pages#dashboard'
end