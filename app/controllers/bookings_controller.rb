class BookingsController < ApplicationController
  before_action :set_room, only: [:new, :create, :edit, :update, :destroy, :finalize_booking]
  before_action :set_booking, only: [:edit, :update, :destroy, :cancel, :finalize_booking]

  # Nouvelle réservation
  def new
    @booking = @room.bookings.new(
      start_date: params[:start_date],
      end_date: params[:end_date],
      first_name: current_user.first_name,
      last_name: current_user.last_name,
      email: current_user.email,
      phone: current_user.phone,
      address: current_user.address
    )
    session[:booking_token] = SecureRandom.uuid # Crée un jeton unique pour la réservation
  end
  
  # Création d'une réservation
  def create
    @booking = @room.bookings.build(booking_params)
    @booking.user = current_user

    if dates_available?(@booking.start_date, @booking.end_date) && @booking.save
      session[:booking_id] = @booking.id
      redirect_to new_room_booking_payment_path(@room, @booking), notice: 'Réservation créée avec succès, veuillez procéder au paiement.'
    else
      flash.now[:alert] = "Erreur lors de la création de la réservation."
      render :new
    end
  end

  # Annuler une réservation
  def cancel
    if @booking.update(status: 'canceled')
      flash[:notice] = 'Votre réservation a été annulée avec succès.'
      redirect_to dashboard_path
    else
      flash[:alert] = "L'annulation de la réservation a échoué."
      redirect_to dashboard_path
    end
  end

  # Mettre à jour une réservation
  def update
    if @booking.update(booking_params)
      redirect_to resolve_redirect_path, notice: 'Réservation mise à jour avec succès.'
    else
      flash.now[:alert] = 'Il y a eu des erreurs lors de la mise à jour de la réservation.'
      render :edit
    end
  end

  # Supprimer une réservation
  def destroy
    if @booking.destroy
      flash[:notice] = 'Réservation supprimée avec succès.'
      redirect_back(fallback_location: room_path(@room))
    else
      flash[:alert] = 'La suppression de la réservation a échoué.'
      redirect_back(fallback_location: room_path(@room))
    end
  end

  # Finaliser la réservation
  def finalize_booking
    if request.post?
      redirect_based_on_params
    else
      render :finalize_booking
    end
  end

  def dates_available?(start_date, end_date)
    overlapping_bookings = @room.bookings.where.not(id: @booking&.id)
                                         .where("start_date < ? AND end_date > ?", end_date, start_date)
                                         .exists?
    !overlapping_bookings
  end
  

  private

  def resolve_redirect_path
    if params[:continue]
      new_room_booking_payment_path(@room, @booking)
    elsif params[:quote]
      room_path(@room)
    else
      room_path(@room)
    end
  end

  def redirect_based_on_params
    if params[:continue]
      redirect_to new_room_booking_payment_path(room_id: @booking.room.id, booking_id: @booking.id), notice: 'Procédez au paiement.'
    elsif params[:quote]
      @booking.update(devis_requested_at: Time.current, status: 'pending')
      flash[:notice] = 'Votre demande de devis a été envoyée. Vous pouvez finaliser votre réservation dans les 24 heures.'
      redirect_to room_path(@booking.room)
    else
      flash.now[:alert] = 'Veuillez choisir une option.'
      render :finalize_booking
    end
  end

  def set_room
    @room = Room.find(params[:room_id])
  end

  def set_booking
    @booking = @room.bookings.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:first_name, :last_name, :email, :phone, :address, :start_date, :end_date)
  end
end
