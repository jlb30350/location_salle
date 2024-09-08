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

  # Bootstrap test
  get 'test_bootstrap', to: 'application#test_bootstrap'

  # Devise configuration
  devise_for :users
  devise_scope :user do
    delete 'delete_account', to: 'users/registrations#destroy', as: :delete_user_account
  end

  # Reviews
  resources :reviews, only: [:create]

  # Dashboard
  resources :dashboard do
    collection do
      delete 'clear_all_bookings'
    end
  end

  resources :rooms do
    member do
      delete 'delete_main_photo'  # Route pour supprimer la photo principale
    end
  end
  
  resources :rooms do
    member do
      delete 'delete_main_photo'
      delete 'delete_additional_photo'  # Route pour supprimer les photos supplémentaires
    end
  end
  
  resources :dashboard, only: [:index] do
    delete 'clear_all_bookings', on: :collection # Pour la suppression des réservations par l'admin
  end
  
  resources :bookings do
    member do
      post :cancel  # Route pour annuler une réservation
    end
  end


  # Rooms and bookings routes
  resources :rooms do
    collection do
      get 'my_rooms', to: 'rooms#my_rooms', as: :my_rooms
      get 'confirmation'
      get 'search'
    end

    member do
      get 'availability'
    end

    # Imbrication des réservations dans les chambres
    resources :bookings, only: [:new, :create, :edit, :update, :destroy] do
      member do
        get 'finalize_booking'
        post 'finalize_booking'
      end
      resources :payments, only: [:new, :create]
    end
  end

  # Route pour les créneaux horaires et formulaires dynamiques
  get 'get_time_slots', to: 'rooms#get_time_slots', as: :get_time_slots
  get 'get_form', to: 'rooms#get_form', as: :get_form

  # Changement de rôle utilisateur
  post 'switch_role', to: 'users#switch_role', as: :switch_role

  # Page d'accueil
  root to: 'pages#home'
end
