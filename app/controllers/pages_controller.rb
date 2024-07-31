class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def home
    @featured_rooms = Room.order(created_at: :desc).limit(3)
  end

  def search
    @rooms = Room.all
    @rooms = @rooms.where("price <= ?", params[:max_price]) if params[:max_price].present?
    @rooms = @rooms.where(event_type: params[:event_type]) if params[:event_type].present?
    @rooms = @rooms.joins(:amenities).where(amenities: { name: params[:amenities] }) if params[:amenities].present?
  end

  def dashboard
    if current_user.nil?
      redirect_to root_path, notice: "Vous avez été redirigé vers la page d'accueil."
      return
    end

    @user_rooms = current_user.rooms
    @user_bookings = current_user.bookings
    # Render the dashboard view here if necessary
  end

  def faq
    @faqs = Faq.all
  end
end
