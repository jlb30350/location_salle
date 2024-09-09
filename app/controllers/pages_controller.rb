class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def home
    @latest_rooms = Room.order(created_at: :desc).limit(3)
    @latest_reviews = Review.order(created_at: :desc).limit(3)
    @testimonials = Testimonial.limit(5)
    @featured_rooms = Room.order(created_at: :desc).limit(3)
    @room = Room.all # ou toute autre logique que vous utilisez pour obtenir les rooms
  end

  def dashboard
    @user_rooms = current_user.rooms
    @user_bookings = current_user.bookings.includes(:room)
  end

  def about; end

  def contact; end

  def faq; end

  def terms; end

  def privacy; end

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
