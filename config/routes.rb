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

  # Route pour tester Bootstrap
  get 'test_bootstrap', to: 'application#test_bootstrap'

  # Configuration Devise pour l'authentification des utilisateurs
  devise_for :users
  devise_scope :user do
    delete 'delete_account', to: 'users/registrations#destroy', as: :delete_user_account
  end

  # Routes pour les avis
  resources :reviews, only: [:create]

  resources :rooms do
    resources :bookings, only: [:new, :create, :edit, :update, :destroy]
  end
  

  # Routes pour les chambres (rooms)
  resources :rooms do
    collection do
      get 'my_rooms', to: 'rooms#my_rooms', as: :my_rooms
      get 'confirmation'
      get 'search'
    end

    member do
      get 'availability'  # Affichage de la disponibilité d'une chambre
    end

    # Routes imbriquées pour les réservations et les paiements
    resources :bookings do
      member do
        post 'finalize', to: 'bookings#finalize_booking', as: 'finalize'  # Finalisation de la réservation
      end

      resources :payments, only: [:new, :create]  # Routes pour les paiements
    end
  end

  # Route pour charger les créneaux horaires via une méthode AJAX
  get 'get_time_slots', to: 'rooms#get_time_slots', as: :get_time_slots

  # Route pour charger dynamiquement un formulaire basé sur la durée et la date
  get 'get_form', to: 'rooms#get_form', as: :get_form

  # Route pour le changement de rôle utilisateur
  post 'switch_role', to: 'users#switch_role', as: :switch_role

  # Page d'accueil par défaut
  root to: 'pages#home'
end
