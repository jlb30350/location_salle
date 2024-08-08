class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def dashboard
    @user_rooms = current_user.rooms if current_user
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
