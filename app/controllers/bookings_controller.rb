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
  end
  
  # Annuler une réservation
  def cancel
    if @booking.update(status: 'canceled')
      flash[:notice] = 'Votre réservation a été annulée avec succès.'
    else
      flash[:alert] = "L'annulation de la réservation a échoué."
    end
    redirect_to dashboard_path
  end

  # Création d'une réservation
  def create
    @booking = @room.bookings.new(booking_params)
    @booking.user = current_user

    # Vérifier et ajuster les dates si elles sont manquantes
    if @booking.start_date.blank? || @booking.end_date.blank?
      @booking.start_date = Date.today
      @booking.end_date = @booking.start_date + 1.day
    end

    adjust_booking_dates(@booking)

    if dates_available?(@booking.start_date, @booking.end_date) && @booking.save
      session[:booking_id] = @booking.id
      redirect_to new_room_booking_payment_path(@room, @booking), notice: 'Réservation créée avec succès, veuillez procéder au paiement.'
    else
      flash.now[:alert] = "Erreur lors de la création de la réservation : #{@booking.errors.full_messages.join(', ')}"
      render :new
    end
  end

  # Finaliser la réservation
  def finalize_booking
    if params[:quote]
      @booking.update(devis_requested_at: Time.current, status: 'pending')
      redirect_to room_path(@room), notice: 'Demande de devis envoyée. Vous avez 24h pour finaliser la réservation.'
    elsif params[:continue]
      redirect_to new_room_booking_payment_path(@room, @booking), notice: 'Procédez au paiement.'
    else
      flash.now[:alert] = 'Veuillez choisir une option.'
      render :finalize_booking
    end
  end

  # Mettre à jour une réservation
  def update
    if @booking.update(booking_params)
      if params[:continue]
        redirect_to new_room_booking_payment_path(@room, @booking), notice: 'Réservation mise à jour avec succès. Veuillez procéder au paiement.'
      elsif params[:quote]
        redirect_to room_path(@room), notice: 'Réservation mise à jour avec succès. Votre demande de devis a été envoyée.'
      else
        redirect_to room_path(@room), notice: 'Réservation mise à jour avec succès.'
      end
    else
      flash.now[:alert] = 'Il y a eu des erreurs lors de la mise à jour de la réservation.'
      render :edit
    end
  end

  # Supprimer une réservation
  def destroy
    if @booking.destroy
      flash[:notice] = 'Réservation supprimée avec succès.'
      redirect_to params[:from_dashboard] ? dashboard_path : room_path(@room)
    else
      flash[:alert] = 'La suppression de la réservation a échoué.'
      redirect_to room_path(@room)
    end
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  end

  def set_booking
    @booking = @room.bookings.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:first_name, :last_name, :email, :phone, :address, :start_date, :end_date, :duration, :number_of_guests)
  end

  def dates_available?(start_date, end_date)
    overlapping_bookings = Booking.where(room_id: @room.id)
                                  .where("start_date < ? AND end_date > ?", end_date, start_date)
    overlapping_bookings.none? do |booking|
      (start_date < booking.end_date && end_date > booking.start_date)
    end
  end

  def adjust_booking_dates(booking)
    case booking.duration
    when 'one_hour'
      booking.start_date = booking.start_date.change(hour: 7)
      booking.end_date = booking.start_date.change(hour: 17)
    when 'one_day'
      booking.start_date = booking.start_date.change(hour: 7)
      booking.end_date = booking.start_date.change(hour: 17)
    when 'multiple_days'
      booking.start_date = booking.start_date.change(hour: 7)
      booking.end_date = booking.end_date.change(hour: 17)
      if (booking.end_date - booking.start_date).to_i > 6
        flash.now[:alert] = "La durée maximale pour '2 à 6 jours' est de 6 jours."
        render :new and return
      end
      if booking.start_date.wday == 0 || (booking.end_date.wday == 0 && booking.duration == 'multiple_days')
        flash.now[:alert] = "Les réservations ne peuvent pas commencer ou se terminer un dimanche."
        render :new and return
      end
    when 'week'
      booking.start_date = booking.start_date.change(hour: 7)
      booking.end_date = booking.start_date + 6.days.change(hour: 17)
    when 'weekend'
      booking.start_date = booking.start_date.change(hour: 7, wday: 6)
      booking.end_date = booking.start_date.change(hour: 17, wday: 0)
    when 'month'
      booking.start_date = booking.start_date.change(hour: 7)
      booking.end_date = booking.start_date + 1.month.change(hour: 17)
    when 'year'
      booking.start_date = booking.start_date.change(hour: 7)
      booking.end_date = booking.start_date + 1.year.change(hour: 17)
    end
  end
end
