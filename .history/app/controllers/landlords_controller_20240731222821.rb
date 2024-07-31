# app/controllers/landlords_controller.rb
class LandlordsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_landlord_role
  
    def dashboard
      @rooms = current_user.rooms
    end
  
    private
  
    def ensure_landlord_role
      unless current_user.landlord?
        redirect_to root_path, alert: "Accès non autorisé"
      end
    end
  end