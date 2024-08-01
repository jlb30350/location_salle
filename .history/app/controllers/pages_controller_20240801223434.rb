class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def home
    @featured_rooms = Room.order(created_at: :desc).limit(3)
  end

  def search
    query = params[:query]
    
    if query.present?
      # Vérifiez si la requête est un code postal (5 chiffres)
      if query.match?(/^\d{5}$/)
        @spaces = Space.where(department: query)
      else
        # Sinon, recherchez par nom de ville
        @spaces = Space.where("city ILIKE ?", "%#{query}%")
      end
    else
      @spaces = Space.none
    end
  
    render :search
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
