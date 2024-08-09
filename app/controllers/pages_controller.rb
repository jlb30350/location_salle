class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def home
    @testimonials = Testimonial.order(created_at: :desc).limit(3)
    @spaces = Space.all # ou toute autre logique que vous utilisez pour obtenir les espaces
  end

  def dashboard
    @user_rooms = current_user.rooms
    @user_bookings = current_user.bookings
  end

  def home
    @rooms = Room.limit(3).order(created_at: :desc)
  end

  def about
  end

  def contact
  end

  def faq
  end

  def terms
  end

  def privacy
  end

  def search
    query = params[:query].to_s.strip.downcase
    @rooms = if query.present?
               Room.where("LOWER(city) LIKE ? OR department LIKE ? OR LOWER(address) LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
             else
               Room.none
             end
    render 'rooms/index'
  end
end
