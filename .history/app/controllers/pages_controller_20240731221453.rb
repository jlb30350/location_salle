class PagesController < ApplicationController
  def home
  end

  def dashboard
    authenticate_user!
    @user_rooms = current_user.rooms
    @user_bookings = current_user.bookings
  end
end