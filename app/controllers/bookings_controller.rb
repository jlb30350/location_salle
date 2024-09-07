class BookingsController < ApplicationController
  before_action :set_room, only: [:new, :create, :edit, :update, :destroy, :finalize_booking]
  before_action :set_booking, only: [:edit, :update, :destroy, :finalize_booking]

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

  # Création d'une réservation
  def create
    @booking = @room.bookings.new(booking_params)
    @booking.user = current_user
    
    if @booking.start_date.blank? || @booking.end_date.blank?
      @booking.start_date = Date.today
      @booking.end_date = @booking.start_date + 1.day
    end
  
    Rails.logger.debug "Start date: #{@booking.start_date}, End date: #{@booking.end_date}"
    Rails.logger.debug "Booking parameters: #{booking_params.inspect}"
    Rails.logger.debug "Booking valid?: #{@booking.valid?}"
    Rails.logger.debug "Booking errors: #{@booking.errors.full_messages}"
  
    # Ajuster les dates et heures en fonction de la durée
    case @booking.duration
    when 'one_hour'
      @booking.start_date = @booking.start_date.change(hour: 7)
      @booking.end_date = @booking.start_date.change(hour: 17)
    when 'one_day'
      @booking.start_date = @booking.start_date.change(hour: 7)
      @booking.end_date = @booking.start_date.change(hour: 17)
    when 'multiple_days'
      @booking.start_date = @booking.start_date.change(hour: 7)
      @booking.end_date = @booking.end_date.change(hour: 17)
      
      # Vérification que la réservation respecte la durée de 6 jours maximum
      if (@booking.end_date - @booking.start_date).to_i > 6
        flash.now[:alert] = "La durée maximale pour '2 à 6 jours' est de 6 jours."
        render :new and return
      end
  
      # Interdire les réservations qui commencent ou se terminent un dimanche
      if @booking.start_date.wday == 0 || (@booking.end_date.wday == 0 && @booking.duration == 'multiple_days')
        flash.now[:alert] = "Les réservations ne peuvent pas commencer ou se terminer un dimanche."
        render :new and return
      end
    when 'week'
      @booking.start_date = @booking.start_date.change(hour: 7)
      @booking.end_date = @booking.start_date + 6.days
      @booking.end_date = @booking.end_date.change(hour: 17)
    when 'weekend'
      @booking.start_date = @booking.start_date.change(hour: 7, wday: 6) # Commence samedi
      @booking.end_date = @booking.start_date.change(hour: 17, wday: 0)  # Finit dimanche
    when 'month'
      @booking.start_date = @booking.start_date.change(hour: 7)
      @booking.end_date = @booking.start_date + 1.month
      @booking.end_date = @booking.end_date.change(hour: 17)
    when 'year'
      @booking.start_date = @booking.start_date.change(hour: 7)
      @booking.end_date = @booking.start_date + 1.year
      @booking.end_date = @booking.end_date.change(hour: 17)
    end
  
    Rails.logger.debug "Checking dates availability..."
    
    # Vérifier la disponibilité des dates et sauvegarder
    if dates_available?(@booking.start_date, @booking.end_date) && @booking.save
      redirect_to finalize_booking_room_booking_path(@room, @booking), notice: 'Réservation créée avec succès, veuillez finaliser.'
    else
      Rails.logger.debug "Booking save failed. Errors: #{@booking.errors.full_messages.join(", ")}"
      flash.now[:alert] = "Erreur lors de la création de la réservation : #{@booking.errors.full_messages.join(", ")}"
      render :new
    end
  end

  # Finaliser la réservation
  def finalize_booking
    if request.post?
      if params[:continue]
        redirect_to new_room_booking_payment_path(room_id: @room.id, booking_id: @booking.id), notice: 'Procédez au paiement.'
      elsif params[:quote]
        redirect_to room_path(@room), notice: 'Demande de devis envoyée.'
      else
        flash.now[:alert] = 'Veuillez choisir une option.'
        render :finalize_booking
      end
    else
      render :finalize_booking
    end
  end

  # Sélection des dates avant la création d'une réservation
  def select_dates
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
    # Recherche des réservations qui se chevauchent dans la même salle
    overlapping_bookings = Booking.where(room_id: @room.id)
                                  .where("start_date < ? AND end_date > ?", end_date, start_date)
  
    # Vérification des chevauchements horaires
    overlapping_bookings.each do |booking|
      if (start_date < booking.end_date && end_date > booking.start_date) &&
         (start_date.hour < booking.end_date.hour || end_date.hour > booking.start_date.hour)
        Rails.logger.debug "Booking overlaps with an existing one"
        return false
      end
    end
  
    Rails.logger.debug "No overlapping bookings"
    true
  end
end
