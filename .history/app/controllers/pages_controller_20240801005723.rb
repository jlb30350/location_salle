# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def home
    @featured_rooms = Room.order(created_at: :desc).limit(3)
  end

  # app/controllers/pages_controller.rb
  def search
    @rooms = Room.all
    @rooms = @rooms.where("price <= ?", params[:max_price]) if params[:max_price].present?
    @rooms = @rooms.where(event_type: params[:event_type]) if params[:event_type].present?
    @rooms = @rooms.joins(:amenities).where(amenities: { name: params[:amenities] }) if params[:amenities].present?
  end

  def dashboard
    render plain: "Bienvenue sur votre tableau de bord."
    authenticate_user!
    @user_rooms = current_user.rooms
    @user_bookings = current_user.bookings
  end

  def faq
    @faqs = Faq.all
  end

end