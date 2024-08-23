# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
    def index
      if current_user.bailleur?
        @rooms = current_user.rooms
        render 'bailleur_dashboard'
      else
        @bookings = current_user.bookings
        render 'client_dashboard'
      end
    end
  end