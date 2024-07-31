# app/controllers/landlords_controller.rb
class LandlordsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_landlord_role
  
    def dashboard
      @rooms = current_user.rooms
    end
  
    def revenue_dashboard
        @rooms = current_user.rooms
        @total_revenue = @rooms.sum { |room| room.bookings.sum(&:total_price) }
        @upcoming_bookings = current_user.rooms.map(&:bookings).flatten.select { |b| b.start_date > Date.today }
        @monthly_revenue = @rooms.map { |room| room.bookings.group_by_month(:start_date).sum(:total_price) }
      end


    private
  
    def ensure_landlord_role
      unless current_user.landlord?
        redirect_to root_path, alert: "Accès non autorisé"
      end
    end
  end