class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_space
  before_action :set_booking, only: [:edit, :update, :destroy]

  def new
    @booking = @space.bookings.new
  end

  def create
    @booking = @space.bookings.new(booking_params)
    @booking.user = current_user
    @booking.status = 'pending' # ou 'confirmed', selon votre logique
  
    if @booking.save
      BookingMailer.confirmation_email(@booking).deliver_later
      redirect_to new_payment_path(booking_id: @booking.id), notice: 'Réservation créée avec succès. Veuillez procéder au paiement.'
    else
      flash.now[:alert] = 'Il y a eu des erreurs lors de la création de votre réservation.'
      render :new
    end
  end

  def update
    if @booking.update(booking_params)
      redirect_to space_booking_path(@space, @booking), notice: 'Réservation mise à jour avec succès.'
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

  def set_space
    @space = Space.find(params[:space_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Espace non trouvé.'
  end

  def set_booking
    @booking = @space.bookings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to space_path(@space), alert: 'Réservation non trouvée.'
  end

  def booking_params
    params.require(:booking).permit(:start_date, :start_time, :duration, :email, :phone, :address, :hour_count, :day_count, :week_count, :month_count, :year_count)
  end
end
