# app/controllers/landlords_controller.rb
class LandlordsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_landlord_role
  
    def dashboard
      @rooms = current_user.rooms
    end
  
    def revenue_dashboard
        @rooms = current_user.rooms
        @total_revenue = @rooms.joins(:bookings).sum('bookings.total_price')
        @upcoming_bookings = current_user.rooms.joins(:bookings)
                                        .where('bookings.start_date > ?', Date.today)
                                        .order('bookings.start_date')
        @monthly_revenue = @rooms.joins(:bookings)
                                 .group_by_month('bookings.start_date')
                                 .sum('bookings.total_price')
        @room_revenue = @rooms.joins(:bookings)
                              .group('rooms.id')
                              .sum('bookings.total_price')
      end
    end

    private
  
    def ensure_landlord_role
      unless current_user.landlord?
        redirect_to root_path, alert: "Accès non autorisé"
      end
    end
  end