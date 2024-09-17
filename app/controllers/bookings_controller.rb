class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :set_booking, only: [:edit, :update, :destroy, :finalize_booking, :cancel]




  

  # Créer une nouvelle réservation
  def create
    @booking = @room.bookings.build(booking_params)

    if @booking.save
      redirect_to @room, notice: 'Réservation créée avec succès.'
    else
      render :new
    end
  end

  # Finaliser la réservation
  def create
    @room = Room.find(params[:room_id])
    @booking = @room.bookings.build(booking_params.merge(user: current_user))
  
    # Assigner les dates manquantes si elles ne sont pas dans le formulaire
    @booking.start_date ||= Date.parse(params[:start_date]) if params[:start_date].present?
    @booking.end_date ||= Date.parse(params[:end_date]) if params[:end_date].present?
  
    if @booking.save
      redirect_to payment_booking_path(@booking)
    else
      flash.now[:error] = "Impossible de créer la réservation. Vérifiez les informations."
      render :finalize_booking
    end
  end
  
  def destroy
    @booking.destroy
    flash[:success] = "La réservation a été supprimée avec succès."
    redirect_to dashboard_path # Si tu as une route de tableau de bord utilisateur
  end
  



  def finalize_booking
    @room = Room.find(params[:room_id])
    @booking = @room.bookings.build(user: current_user)
    # Aucune validation à ce stade
    render 'finalize_booking'
  end
  


  # Annuler une réservation
  def cancel
    @booking.update(status: 'cancelled')
    flash[:notice] = 'Réservation annulée avec succès.'
    redirect_to dashboard_path
  end

  def payment
    @booking = Booking.find(params[:id])
    # Logique pour afficher la page de paiement
  end
  

  private

  def set_room
    @room = Room.find(params[:room_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Salle non trouvée."
    redirect_to rooms_path
  end

  def set_booking
    @booking = Booking.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Réservation non trouvée."
    redirect_to room_path(@room)
  end

  def booking_params
    params.require(:booking).permit(:first_name, :last_name, :email, :phone, :address, :start_date, :end_date, :start_time, :end_time, :room_id)
  end
end

