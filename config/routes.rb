Rails.application.routes.draw do
  root 'pages#home'
  
  devise_for :users, controllers: { registrations: 'users/registrations' }

  # Routes pour les pages statiques
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'
  get 'faq', to: 'pages#faq'
  get 'terms', to: 'pages#terms'
  get 'privacy', to: 'pages#privacy'
  get 'dashboard', to: 'pages#dashboard'
  get 'load_google_maps', to: 'google_maps#load_script'



  # Suppression de compte
  devise_scope :user do
    delete 'delete_account', to: 'users/registrations#destroy', as: :delete_user_account
  end
  
  # Routes pour les espaces (spaces)
  resources :spaces do
    collection do
      get 'search_location'
      get 'search'
    end
  end
  get '/search_spaces', to: 'spaces#search'
  get '/api/spaces', to: 'spaces#search'

  # Routes pour les salles (rooms)
  resources :rooms do
    member do
      delete 'photos/:photo_id', to: 'rooms#delete_photo', as: 'delete_photo'
    end
    resources :bookings, only: [:new, :create]
    resources :payments, only: [:new, :create]
    resources :reviews, only: [:create]
    resources :reservations, only: [:index, :show, :edit, :update, :destroy]

    collection do
      get 'my_rooms', to: 'rooms#my_rooms', as: :my_rooms  # Route pour les salles du propriétaire
      get 'confirmation'
      get 'search'
    end
  end

  # Route pour le changement de rôle utilisateur
  post 'switch_role', to: 'users#switch_role', as: :switch_role
end
