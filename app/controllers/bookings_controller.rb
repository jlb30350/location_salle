class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :set_booking, only: [:edit, :update, :destroy, :finalize_booking, :cancel]


  def new
    @room = Room.find(params[:room_id])
    @booking = @room.bookings.build(user: current_user)
    @booking.start_date ||= Date.today
    @booking.end_date ||= Date.today
    @booking.start_time ||= Time.now.change(hour: 7)
    @booking.end_time ||= Time.now.change(hour: 17)
  end
  


  def index
    @room = Room.find(params[:room_id])
    @bookings = @room.bookings
  end

  def show
    @booking = Booking.find(params[:id])
  end



  

  def create
    @booking = @room.bookings.new(booking_params.merge(user: current_user))


    if @booking.save
      flash[:notice] = 'Réservation effectuée avec succès.'
      redirect_to room_path(@booking.room)
    else
      flash.now[:alert] = @booking.errors.full_messages.to_sentence # Affiche les erreurs
      render :new
    end
  end

  
 
  
  
  
  
  
  
  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
    flash[:notice] = "Réservation supprimée avec succès."
    redirect_to room_path(@booking.room)
  end
  
  



  def finalize_booking
    @booking = @room.bookings.build(user: current_user)
    @booking.start_date ||= params[:start_date] || Time.zone.today
    @booking.end_date ||= params[:end_date] || Time.zone.today
    @booking.start_time ||= Time.zone.now.change(hour: 7) # ou utilisez la valeur transmise
    @booking.end_time ||= Time.zone.now.change(hour: 17) # ou utilisez la valeur transmise
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

  # Méthode pour trouver la salle
  def set_room
    @room = Room.find(params[:room_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Salle non trouvée."
    redirect_to rooms_path
  end

  # Méthode pour trouver la réservation
  def set_booking
    @booking = Booking.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Réservation non trouvée."
    redirect_to room_path(@room)
  end

  # Filtrage des paramètres pour les réservations
  def booking_params
    params.require(:booking).permit(:first_name, :last_name, :email, :phone, :start_date, :end_date, :start_time, :end_time, :room_id)
  end
end
