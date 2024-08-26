class BookingsController < ApplicationController
  def create
    @booking = @room.bookings.new(booking_params)
    @booking.user = current_user
    @booking.status = 'pending'

    if dates_available?(@booking.start_date, @booking.end_date)
      if @booking.save
        # Rediriger vers la page de paiement
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
end
