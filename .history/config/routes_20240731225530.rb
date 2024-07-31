# config/routes.rb
Rails.application.routes.draw do
  root 'pages#home'
  
  devise_for :users
  
  resources :rooms do
    resources :bookings, only: [:new, :create]
    resources :reviews, only: [:create]
  end

  def faq
    @faqs = Faq.all
  end
  
  get 'search', to: 'pages#search'
  get 'dashboard', to: 'pages#dashboard'
  get '/search_spaces', to: 'spaces#search'
end