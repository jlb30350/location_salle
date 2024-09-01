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
  
    # Log pour vérifier les valeurs de params
    Rails.logger.debug "Params start date: #{params[:start_date]}, Params end date: #{params[:end_date]}"
  
    # Initialisation de la réservation
    @booking = @room.bookings.new(
      number_of_guests: params[:number_of_guests],
      address: params[:address],
      phone: params[:phone],
      email: params[:email],
      duration: params[:duration]
    )

    # Vérification que les dates sont présentes et les convertir
    if params[:start_date].present? && params[:end_date].present?
      begin
        @booking.start_date = Date.parse(params[:start_date])
        @booking.end_date = Date.parse(params[:end_date])
      rescue ArgumentError => e
        Rails.logger.debug "Erreur de conversion de date: #{e.message}"
        flash.now[:alert] = "Les dates fournies ne sont pas valides."
        render :new and return
      end
    else
      Rails.logger.debug "Les dates ne sont pas présentes dans les paramètres"
    end

    # Log pour vérifier les dates après conversion
    Rails.logger.debug "Booking start date: #{@booking.start_date}, Booking end date: #{@booking.end_date}"
  end

  # Créer une réservation
  def create
    Rails.logger.debug "Start date: #{params[:booking][:start_date]}, End date: #{params[:booking][:end_date]}"

    @booking = current_user.bookings.new(booking_params)
    @booking.room = @room

    if dates_available?(@booking.start_date, @booking.end_date)
      if @booking.save
        redirect_to new_room_booking_payment_path(room_id: @booking.room.id, booking_id: @booking.id), notice: 'Réservation créée avec succès. Veuillez vérifier votre email pour le devis et procéder au paiement.'
      else
        Rails.logger.debug @booking.errors.full_messages.join(", ")
        flash.now[:alert] = 'Il y a eu des erreurs lors de la création de votre réservation.'
        render :new
      end
    else
      flash.now[:alert] = "Les dates choisies ne sont pas disponibles."
      render :new
    end
  end

  # Modifier une réservation
  def edit
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
    params.require(:booking).permit(:start_date, :end_date, :number_of_guests, :address, :phone, :email, :duration)
  end

  def dates_available?(start_date, end_date)
    @room.bookings.where.not(id: @booking.try(:id)).where("start_date <= ? AND end_date >= ?", end_date, start_date).empty?
  end
end
