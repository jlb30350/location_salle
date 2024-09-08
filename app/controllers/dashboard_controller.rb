class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin, only: [:clear_all_bookings]

  def index
    if current_user.bailleur?
      @rooms = current_user.rooms
      render 'bailleur_dashboard'
    else
      @bookings = current_user.bookings
      render 'client_dashboard'
    end
  end

  def clear_all_bookings
    Booking.delete_all
    flash[:notice] = "Toutes les réservations ont été supprimées."
    redirect_to dashboard_path
  end

  private

  # Assurez-vous que seul un administrateur peut accéder à cette action
  def ensure_admin
    unless current_user.admin?
      flash[:alert] = "Vous n'avez pas la permission d'effectuer cette action."
      redirect_to dashboard_path
    end
  end
end
