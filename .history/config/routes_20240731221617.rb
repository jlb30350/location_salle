Rails.application.routes.draw do

  root 'pages#home'
  
  devise_for :users
  
  resources :rooms do
    resources :bookings, only: [:new, :create]
    resources :reviews, only: [:create]
  end
  
  get 'dashboard', to: 'pages#dashboard'
end




  devise_for :users
  get 'pages/home'
  get 'pages/search'
  get 'reviews/create'
  get 'bookings/new'
  get 'bookings/create'
  get 'bookings/index'
  get 'rooms/index'
  get 'rooms/show'
  get 'rooms/new'
  get 'rooms/create'
  get 'rooms/edit'
  get 'rooms/update'
  get 'rooms/destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
