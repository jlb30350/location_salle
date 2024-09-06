class BookingsController < ApplicationController
  before_action :set_room, only: [:new, :create, :edit, :finalize_booking]
  before_action :set_booking, only: [:edit, :update, :destroy, :finalize_booking]

  # Nouvelle réservation
  def new
    @room = Room.find(params[:room_id])
    
    # Utilisation des dates transmises ou valeurs par défaut
    @booking = @room.bookings.new(
      start_date: params[:start_date], # Utiliser les dates transmises dans l'URL
      end_date: params[:end_date],     # Utiliser les dates transmises dans l'URL
      first_name: current_user.first_name,
      last_name: current_user.last_name,
      email: current_user.email,
      phone: current_user.phone,
      address: current_user.address
    )
  end

  def create
    @room = Room.find(params[:room_id])
    @booking = @room.bookings.new(booking_params)
    @booking.user = current_user
  
    # Si aucune date de début ou de fin n'est fournie, utiliser des valeurs par défaut
    if @booking.start_date.blank? || @booking.end_date.blank?
      @booking.start_date = Date.today
      @booking.end_date = @booking.start_date + 1.day
    end
  
    Rails.logger.debug "Start date: #{@booking.start_date}, End date: #{@booking.end_date}"
    Rails.logger.debug "Booking parameters: #{booking_params.inspect}"
    Rails.logger.debug "Booking valid?: #{@booking.valid?}"
    Rails.logger.debug "Booking errors: #{@booking.errors.full_messages}"
  
    # Vérifier la durée et ajuster la date de fin
    case @booking.duration
    when 'one_day'
      @booking.end_date = @booking.start_date
    when 'multiple_days'
      if (@booking.end_date - @booking.start_date).to_i > 6
        flash.now[:alert] = "La durée maximale pour '2 à 6 jours' est de 6 jours."
        render :new and return
      end
    when 'week'
      @booking.end_date = @booking.start_date + 6.days
    when 'month'
      @booking.end_date = @booking.start_date + 1.month
    when 'year'
      @booking.end_date = @booking.start_date + 1.year
    end
  
    Rails.logger.debug "Checking dates availability..."
    
    # Vérifier la disponibilité des dates et sauvegarder
    if dates_available?(@booking.start_date, @booking.end_date) && @booking.save
      Rails.logger.debug "Booking saved successfully."
      redirect_to finalize_booking_room_booking_path(@room, @booking), notice: 'Réservation créée avec succès, veuillez finaliser.'
    else
      Rails.logger.debug "Booking save failed. Errors: #{@booking.errors.full_messages.join(", ")}"
      flash.now[:alert] = "Erreur lors de la création de la réservation : #{@booking.errors.full_messages.join(", ")}"
      render :new
    end
  end
  
  
  

  # Finaliser la réservation
  def finalize_booking
    @booking = @room.bookings.find(params[:id])
  
    if request.post?
      if params[:continue]
        # Rediriger vers la page de paiement
        redirect_to new_room_booking_payment_path(room_id: @room.id, booking_id: @booking.id), notice: 'Procédez au paiement.'
      elsif params[:quote]
        # Rediriger vers la demande de devis
        redirect_to room_path(@room), notice: 'Demande de devis envoyée.'
      else
        flash.now[:alert] = 'Veuillez choisir une option.'
        render :finalize_booking
      end
    else
      # Simple affichage du formulaire de finalisation
      render :finalize_booking
    end
  end
  

  # Sélection des dates avant la création d'une réservation
  def select_dates
    @room = Room.find(params[:room_id])
    @selected_start_date = params[:start_date]
    @selected_end_date = params[:end_date]
  
    if @selected_start_date.present? && @selected_end_date.present?
      redirect_to new_room_booking_path(room_id: @room.id, start_date: @selected_start_date, end_date: @selected_end_date)
    else
      flash[:alert] = "Veuillez sélectionner des dates valides."
      redirect_to room_path(@room)
    end
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
    @booking = @room.bookings.find(params[:id])
    if @booking.destroy
      redirect_to room_path(@room), notice: 'Réservation supprimée avec succès.'
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
    return false if start_date.nil? || end_date.nil?
  
    overlapping_bookings = Booking.where(room_id: @room.id)
                                  .where("start_date < ? AND end_date > ?", end_date, start_date)
  
    # Si les dates sont les mêmes, vérifier plus précisément les horaires
    if start_date == end_date
      overlapping_bookings = overlapping_bookings.where.not("start_date = end_date")
    end
  
    overlapping_bookings.empty?
  end
  
end

