Rails.application.routes.draw do
  # Routes pour les pages statiques
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'
  get 'faq', to: 'pages#faq'
  get 'terms', to: 'pages#terms'
  get 'privacy', to: 'pages#privacy'
  get 'dashboard', to: 'pages#dashboard'
  get 'load_google_maps', to: 'google_maps#load_script'
  get 'rooms/:room_id/photos/:id', to: 'rooms#show_photo', as: 'room_photo'

  # Configuration Devise
  devise_for :users
  
  # Suppression de compte
  devise_scope :user do
    delete 'delete_account', to: 'users/registrations#destroy', as: :delete_user_account
  end

  # Routes pour les avis et les réservations
  resources :reviews, only: [:create]
  resources :reservations, only: [:index, :show, :edit, :update, :destroy]

  # Routes pour les chambres, réservations et paiements
  resources :rooms do
    collection do
      get 'my_rooms', to: 'rooms#my_rooms', as: :my_rooms
      get 'confirmation'
      get 'search'
    end

    member do
      get 'availability'  # Route spécifique pour une instance de room
    end


    resources :bookings do
      resources :payments, only: [:new, :create]
    end
  end

  # Route pour le changement de rôle utilisateur
  post 'switch_role', to: 'users#switch_role', as: :switch_role

  # Page d'accueil par défaut
  root to: 'pages#home'
end
