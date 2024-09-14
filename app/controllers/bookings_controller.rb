class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :set_booking, only: [:edit, :update, :destroy, :finalize_booking, :cancel]

  # Créer une nouvelle réservation
  def new
    @booking = @room.bookings.new
  end

  # Enregistrer une nouvelle réservation
  def create
    @booking = @room.bookings.new(booking_params)
    @booking.user = current_user

    if @booking.save
      redirect_to finalize_booking_room_booking_path(@room, @booking), notice: 'Réservation créée avec succès.'
    else
      flash[:alert] = 'Impossible de créer la réservation.'
      render :new
    end
  end

  # Modifier une réservation existante
  def edit
  end

  # Mettre à jour une réservation existante
  def update
    if @booking.update(booking_params)
      redirect_to room_path(@room), notice: 'Réservation mise à jour avec succès.'
    else
      render :edit
    end
  end

  # Supprimer une réservation
  def destroy
    @booking.destroy
    flash[:notice] = 'Réservation supprimée avec succès.'
    redirect_to room_path(@room)
  end

  # Finaliser la réservation
  def finalize_booking
    if request.post?
      # Traitement des informations de paiement ou d'envoi de devis
      redirect_to payment_path(@room, @booking), notice: 'Réservation finalisée.'
    else
      render :finalize_booking
    end
  end

  # Annuler une réservation
  def cancel
    @booking.update(status: 'cancelled')
    flash[:notice] = 'Réservation annulée avec succès.'
    redirect_to dashboard_path
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
    params.require(:booking).permit(:start_date, :end_date, :total_price, :status, :special_requests)
  end
end
