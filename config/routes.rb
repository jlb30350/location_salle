Rails.application.routes.draw do
  # Pages statiques
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'
  get 'faq', to: 'pages#faq'
  get 'terms', to: 'pages#terms'
  get 'privacy', to: 'pages#privacy'
  get 'dashboard', to: 'pages#dashboard'
  get 'load_google_maps', to: 'google_maps#load_script'
  get 'rooms/:room_id/photos/:id', to: 'rooms#show_photo', as: 'room_photo'

  # Test de Bootstrap
  get 'test_bootstrap', to: 'application#test_bootstrap'

  # Configuration de Devise pour les utilisateurs
  devise_for :users
  devise_scope :user do
    delete 'delete_account', to: 'users/registrations#destroy', as: :delete_user_account
  end

  # Avis (Reviews)
  resources :reviews, only: [:create]

  # Tableau de bord (Dashboard)
  resources :dashboard, only: [:index] do
    collection do
      delete 'clear_all_bookings'  # Suppression de toutes les réservations par l'admin
    end
  end

  # Routes pour les chambres et les réservations
  resources :rooms do
    resources :bookings, only: [:create]
    collection do
      get 'my_rooms'
      get 'confirmation'
      get 'search'
    end

    member do
      get 'availability'
      delete 'delete_main_photo'
      delete 'delete_additional_photo'
    end

    resources :bookings, only: [:edit, :update, :destroy]
  end

  # Routes pour les réservations
  resources :bookings, except: [:index, :show] do
    member do
      get 'create_devis', defaults: { format: 'pdf' }
      get 'finalize_booking'
      post 'finalize_booking'
      post 'cancel'
      get 'view_quote', defaults: { format: 'pdf' }
      delete 'destroy'
      get 'payment'
    end

    # Routes pour les paiements
    resources :payments, only: [:new, :create]
  end

  # Route pour obtenir les créneaux horaires disponibles
  get 'get_time_slots', to: 'rooms#get_time_slots', as: :get_time_slots

  # Route pour afficher le formulaire en fonction du type de réservation
  get 'get_form', to: 'rooms#get_form', as: :get_form

  # Route pour afficher la page de paiement pour une réservation spécifique
  get 'rooms/:room_id/bookings/:id/payment', to: 'payments#new', as: 'room_booking_payment'

  # Route pour changer le rôle de l'utilisateur (loueur/bailleur)
  post 'switch_role', to: 'users#switch_role', as: :switch_role

  # Page d'accueil
  root to: 'pages#home'
end
