class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :set_booking, only: [:edit, :update, :destroy, :finalize_booking, :cancel, :payment, :quote]

  def new
    @booking = @room.bookings.build(user: current_user)
    @booking.start_date ||= Date.today
    @booking.end_date ||= Date.today
    @booking.start_time ||= Time.now.change(hour: 7)
    @booking.end_time ||= Time.now.change(hour: 17)
  end

  def create
    @booking = @room.bookings.new(booking_params.merge(user: current_user))

    if @booking.save
      if params[:commit] == 'Payer maintenant'
        redirect_to payment_booking_path(@booking) # Redirige vers la page de paiement
      elsif params[:commit] == 'Voir le devis'
        redirect_to quote_booking_path(@booking) # Redirige vers la page de devis
      else
        flash[:notice] = 'Réservation effectuée avec succès.'
        redirect_to room_path(@booking.room)
      end
    else
      flash.now[:alert] = "Erreur lors de la réservation. Veuillez vérifier les informations."
      render :new
    end
  end

  def destroy
    @booking.destroy
    flash[:notice] = "Réservation supprimée avec succès."
    redirect_to room_path(@booking.room)
  end

  def finalize_booking
    # Cette méthode pourrait être appelée lors de la finalisation d'une réservation
    @booking.start_date ||= params[:start_date] || Time.zone.today
    @booking.end_date ||= params[:end_date] || Time.zone.today
    @booking.start_time ||= Time.zone.now.change(hour: 7)
    @booking.end_time ||= Time.zone.now.change(hour: 17)
  end

  # Annuler une réservation
  def cancel
    @booking.update(status: 'cancelled')
    flash[:notice] = 'Réservation annulée avec succès.'
    redirect_to dashboard_path
  end

  # Page de paiement
  def payment
    # Ajoute ici la logique pour afficher ou traiter la page de paiement
  end

  # Page de devis
  def quote
    # Ajoute ici la logique pour afficher ou générer le devis
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
    params.require(:booking).permit(:first_name, :last_name, :email, :phone, :start_date, :end_date, :start_time, :end_time, :room_id)
  end
end
