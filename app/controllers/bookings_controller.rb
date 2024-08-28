class BookingsController < ApplicationController
  before_action :set_room

  class BookingsController < ApplicationController
    before_action :set_room
  
    def availability
      @room = Room.find(params[:id])
      @bookings = @room.bookings
      Rails.logger.debug("Réservations récupérées : #{@bookings.inspect}")
    end
  end
  
   
  def new
    @booking = @room.bookings.new
  end

  def create
    @booking = @room.bookings.new(booking_params)
    @booking.user = current_user
    @booking.status = 'pending'

    if dates_available?(@booking.start_date, @booking.end_date)
      if @booking.save
        redirect_to new_room_booking_payment_path(room_id: @booking.room.id, booking_id: @booking.id), notice: 'Réservation créée avec succès. Veuillez vérifier votre email pour le devis et procéder au paiement.'
      else
        flash.now[:alert] = 'Il y a eu des erreurs lors de la création de votre réservation.'
        render :new
      end
    else
      flash.now[:alert] = 'Les dates sélectionnées ne sont pas disponibles.'
      render :new
    end
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date, :number_of_guests)
  end

  def dates_available?(start_date, end_date)
    # Logique pour vérifier la disponibilité des dates
    # Vous devez implémenter cette méthode
  end
end
