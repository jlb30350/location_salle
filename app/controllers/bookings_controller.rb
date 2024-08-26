class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :set_booking, only: [:edit, :update, :destroy]

  def new
    @booking = @room.bookings.new(start_date: params[:start_date], end_date: params[:end_date])
  end

  def create
    @booking = @room.bookings.new(booking_params)
    @booking.user = current_user
    @booking.status = 'pending'  # Définir le statut initial à "en attente"

    # Vérification de la disponibilité des dates
    if dates_available?(@booking.start_date, @booking.end_date)
      if @booking.save
        BookingMailer.confirmation_email(@booking).deliver_later
        redirect_to new_payment_path(booking_id: @booking.id), notice: 'Réservation créée avec succès. Veuillez procéder au paiement.'
      else
        flash.now[:alert] = 'Il y a eu des erreurs lors de la création de votre réservation.'
        render :new
      end
    else
      flash.now[:alert] = 'Les dates sélectionnées ne sont pas disponibles.'
      render :new
    end
  end

  def edit
    # Préparation pour l'édition, @booking est déjà défini par set_booking
  end

  def update
    if @booking.update(booking_params)
      redirect_to room_booking_path(@room, @booking), notice: 'Réservation mise à jour avec succès.'
    else
      flash.now[:alert] = 'Il y a eu des erreurs lors de la mise à jour de votre réservation.'
      render :edit
    end
  end

  def destroy
    if @booking.destroy
      redirect_to dashboard_path, notice: 'Réservation annulée avec succès.'
    else
      redirect_to dashboard_path, alert: 'Impossible d\'annuler la réservation.'
    end
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Salle non trouvée.'
  end

  def set_booking
    @booking = @room.bookings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to room_path(@room), alert: 'Réservation non trouvée.'
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date, :email, :phone, :address, :duration)
  end

  def dates_available?(start_date, end_date)
    overlapping_bookings = @room.bookings.where("start_date <= ? AND end_date >= ?", end_date, start_date)
    overlapping_bookings.none?
  end
end
