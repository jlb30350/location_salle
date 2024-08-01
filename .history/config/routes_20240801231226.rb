Rails.application.routes.draw do
  root 'pages#home'
  
  devise_for :users
  
  resources :rooms do
    resources :bookings, only: [:new, :create]
    resources :reviews, only: [:create]
    resources :reservations, only: [:index, :show, :edit, :update, :destroy]

    collection do
      get 'confirmation'
    end
  end

    collection do
      get 'search'
    end
  end

  get 'faq', to: 'pages#faq'
  get 'search', to: 'pages#search'
  get 'dashboard', to: 'pages#dashboard'
  get '/search_spaces', to: 'spaces#search'
  get '/api/spaces', to: 'spaces#search'

  post 'switch_role', to: 'users#switch_role', as: :switch_role
end
