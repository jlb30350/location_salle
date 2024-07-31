# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def home
    @featured_rooms = Room.order(created_at: :desc).limit(3)
  end

  def search
    @rooms = Room.all
    # Ajoutez ici la logique de recherche (vous pouvez utiliser une gem comme Ransack pour une recherche avancée)
  end

  def dashboard
    authenticate_user!
    @user_rooms = current_user.rooms
    @user_bookings = current_user.bookings
  end
end