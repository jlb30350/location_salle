class BookingsController < ApplicationController
  before_action :set_room, only: [:availability, :new, :create, :edit, :update, :destroy]
  before_action :set_booking, only: [:edit, :update, :destroy]

  # Affiche le calendrier de disponibilité
  def availability
    @year = (params[:year] || Date.today.year).to_i
    @month = (params[:month] || Date.today.month).to_i

    # Récupération des réservations pour le mois donné
    first_day_of_month = Date.new(@year, @month, 1)
    last_day_of_month = first_day_of_month.end_of_month

    @bookings = @room.bookings.where("start_date <= ? AND end_date >= ?", last_day_of_month, first_day_of_month)
    Rails.logger.debug("Réservations récupérées pour #{@month}/#{@year} : #{@bookings.inspect}")
  end

  # Nouvelle réservation
  def new
    @room = Room.find(params[:room_id])
    @booking = @room.bookings.new(start_date: params[:start_date], end_date: params[:end_date])
  end
  

  # Créer une réservation
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

  # Modifier une réservation
  def edit
    @room = Room.find(params[:room_id])
    @booking = @room.bookings.find(params[:id])
  end

  # Mettre à jour une réservation
  def update
    if dates_available?(@booking.start_date, @booking.end_date) || (@booking.start_date == booking_params[:start_date] && @booking.end_date == booking_params[:end_date])
      if @booking.update(booking_params)
        redirect_to room_availability_path(@room), notice: 'Réservation mise à jour avec succès.'
      else
        flash.now[:alert] = 'Il y a eu des erreurs lors de la mise à jour de votre réservation.'
        render :edit
      end
    else
      flash.now[:alert] = 'Les nouvelles dates sélectionnées ne sont pas disponibles.'
      render :edit
    end
  end

  # Supprimer une réservation
  def destroy
    @booking.destroy
    redirect_to room_availability_path(@room), notice: 'Réservation supprimée avec succès.'
  end

  private

  def set_room
    @room = Room.find(params[:room_id] || params[:id])
  end

  def set_booking
    @booking = @room.bookings.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date, :number_of_guests)
  end

  def dates_available?(start_date, end_date)
    # Logique pour vérifier la disponibilité des dates
    @room.bookings.where.not(id: @booking.try(:id)).where("start_date <= ? AND end_date >= ?", end_date, start_date).empty?
  end
end
