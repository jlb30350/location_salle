class BookingsController < ApplicationController
  before_action :set_room, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_booking, only: [:edit, :update, :destroy]

  # Nouvelle réservation
  def new
    @booking = @room.bookings.new(
      start_date: params[:start_date],
      end_date: params[:end_date],
      number_of_guests: params[:number_of_guests],
      address: params[:address],
      phone: params[:phone],
      email: params[:email],
      duration: params[:duration],
      start_time: params[:start_time],
      end_time: params[:end_time]
    )
    Rails.logger.debug "New Booking - start_date: #{@booking.start_date}, end_date: #{@booking.end_date}, start_time: #{@booking.start_time}, end_time: #{@booking.end_time}"
  end

  # Créer une réservation
  def create
    @booking = @room.bookings.new(booking_params)
    @booking.user = current_user

    case @booking.duration
    when 'one_day'
      @booking.end_date = @booking.start_date
    when 'multiple_days'
      # Vérifier si la durée dépasse 6 jours
      if (@booking.end_date - @booking.start_date).to_i > 6
        flash.now[:alert] = "La durée maximale pour '2 à 6 jours' est de 6 jours."
        render :new and return
      end
    when 'week'
      # S'assurer que la date de fin correspond à 7 jours après la date de début
      @booking.end_date = @booking.start_date + 6.days
    when 'month'
      @booking.end_date = @booking.start_date + 1.month
    when 'year'
      @booking.end_date = @booking.start_date + 1.year
    end

    # Vérifier les disponibilités des dates
    if dates_available?(@booking.start_date, @booking.end_date)
      if @booking.save
        redirect_to new_room_booking_payment_path(room_id: @booking.room.id, booking_id: @booking.id), notice: 'Réservation créée avec succès.'
      else
        flash.now[:alert] = 'Il y a eu des erreurs lors de la création de votre réservation.'
        render :new
      end
    else
      flash.now[:alert] = "Les dates choisies ne sont pas disponibles. Veuillez sélectionner une autre période."
      render :new
    end
  end

  # Modifier une réservation
  def edit
    # Le rappel set_booking est exécuté avant cette action, donc @booking est déjà défini
  end

  # Mettre à jour une réservation
  def update
    if @booking.update(booking_params)
      redirect_to room_path(@room), notice: 'Réservation mise à jour avec succès.'
    else
      flash.now[:alert] = 'Il y a eu des erreurs lors de la mise à jour de la réservation.'
      render :edit
    end
  end

  # Supprimer une réservation
  def destroy
    if @booking.destroy
      redirect_to room_path(@room), notice: 'Réservation supprimée avec succès.'
    else
      flash[:alert] = 'La suppression de la réservation a échoué.'
      redirect_to room_path(@room)
    end
  end

  # Méthodes privées
  private

  def set_room
    @room = Room.find(params[:room_id])
  end

  def set_booking
    @booking = @room.bookings.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date, :start_time, :end_time, :number_of_guests, :duration, :total_amount, :address, :phone, :email)
  end

  def dates_available?(start_date, end_date)
    overlapping_bookings = @room.bookings.where.not(id: @booking.try(:id))
                                         .where("start_date < ? AND end_date > ?", end_date, start_date)
    overlapping_bookings.empty?
  end
end
