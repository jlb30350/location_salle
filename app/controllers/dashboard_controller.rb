# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
    def index
      if current_user.bailleur?
        @spaces = current_user.spaces
        render 'bailleur_dashboard'
      else
        @bookings = current_user.bookings
        render 'client_dashboard'
      end
    end
  end