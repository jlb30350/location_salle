class RoomsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search, :bookings]
  before_action :set_room, only: [:show, :edit, :update, :destroy, :delete_photo, :delete_additional_photo, :availability, :bookings]
  before_action :ensure_bailleur, only: [:new, :create, :edit, :update, :destroy, :delete_photo, :delete_additional_photo]
  before_action :ensure_owner, only: [:edit, :update, :destroy, :delete_photo, :delete_additional_photo]
  before_action :ensure_bailleur_or_correct_visibility, only: [:show]

  # Liste des salles
  def index
    @rooms = if user_signed_in? && current_user.bailleur?
              current_user.rooms
            else
              Room.where(is_public: true)
            end
  end

  # Créer une nouvelle salle
  def new
    @room = Room.new
  end

  # Afficher une salle spécifique
  def show
    Rails.logger.debug "Room found: #{@room.inspect}"
    if @room
      @booking = @room.bookings.new

      if user_signed_in?
        @detailed_info = {
          address: @room.address,
          surface: @room.surface,
          hourly_rate: @room.hourly_rate,
          daily_rate: @room.daily_rate,
          weekly_rate: @room.weekly_rate,
          monthly_rate: @room.monthly_rate,
          weekend_rate: @room.weekend_rate,
          quarterly_rate: @room.quarterly_rate,
          semiannual_rate: @room.semiannual_rate,
          annual_rate: @room.annual_rate
        }
      end

      begin
        @year = params[:year] ? params[:year].to_i : Date.today.year
        @month = params[:month] ? params[:month].to_i : Date.today.month

        first_day_of_month = Date.new(@year, @month, 1)
        last_day_of_month = first_day_of_month.end_of_month

        @bookings = @room.bookings.where('start_date <= ? AND end_date >= ?', last_day_of_month, first_day_of_month)
      rescue ArgumentError
        flash[:alert] = "Date invalide"
        redirect_to rooms_path and return
      end
    else
      redirect_to rooms_path, alert: 'Salle non trouvée.' and return
    end
  end

  # Supprimer la photo principale
  def delete_main_photo
    @room = Room.find(params[:id])

    if @room.main_photo.attached?
      @room.main_photo.purge # Supprime la photo
      flash[:notice] = 'Photo principale supprimée avec succès.'
    else
      flash[:alert] = 'Aucune photo principale à supprimer.'
    end

    redirect_to rooms_path
  end

  # Supprimer une photo supplémentaire
  def delete_additional_photo
    @room = Room.find(params[:id])
    photo = @room.additional_photos.find_by(id: params[:photo_id])

    if photo.present?
      photo.purge  # Supprime la photo
      flash[:notice] = 'Photo supplémentaire supprimée avec succès.'
    else
      flash[:alert] = 'Aucune photo supplémentaire à supprimer.'
    end

    redirect_to rooms_path
  end

  # Action pour obtenir le formulaire basé sur la durée de réservation
  def get_form
    @room = Room.find(params[:room_id])
    duration = params[:duration]
    start_date = params[:start_date]
    end_date = params[:end_date]
    
    case duration
    when 'multiple_days'
      @message = "Réservation de plusieurs jours du #{start_date} au #{end_date}"
    when 'hour'
      @message = "Réservation d'une heure le #{start_date}"
    when 'day'
      @message = "Réservation d'une journée le #{start_date}"
    when 'weekend'
      @message = "Réservation pour le week-end du #{start_date}"
    when 'week'
      @message = "Réservation pour une semaine commençant le #{start_date}"
    when 'month'
      @message = "Réservation pour un mois commençant le #{start_date}"
    when 'year'
      @message = "Réservation pour une année commençant le #{start_date}"
    else
      @message = "Réservation par défaut"
    end

    # Vous pouvez rediriger ou rendre partiellement une vue
    render partial: 'form_partial', locals: { message: @message, room: @room }
  end

  def create
    @room = current_user.rooms.new(room_params)
    if @room.save
      @room.additional_photos.attach(params[:room][:additional_photos]) if params[:room][:additional_photos].present?
      redirect_to @room, notice: 'Salle ajoutée avec succès.'
    else
      render :new
    end
  end

  def update
    if @room.update(room_params)
      if params[:room][:main_photo].present?
        @room.main_photo.attach(params[:room][:main_photo])
      end
      redirect_to @room, notice: 'Salle mise à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    if @room.destroy
      redirect_to rooms_url, notice: 'La salle a été supprimée avec succès.'
    else
      redirect_to rooms_url, alert: "Impossible de supprimer la salle."
    end
  end

  def availability
    begin
      @year = params[:year] ? params[:year].to_i : Date.today.year
      @month = params[:month] ? params[:month].to_i : Date.today.month

      first_day_of_month = Date.new(@year, @month, 1)
      last_day_of_month = first_day_of_month.end_of_month

      @bookings = @room.bookings.where('start_date <= ? AND end_date >= ?', last_day_of_month, first_day_of_month)
      @booking = @room.bookings.new
    rescue ArgumentError
      flash[:alert] = "Date invalide"
      redirect_to rooms_path
    end

    render :show
  end

  def destroy_booking
    booking = Booking.find(params[:id])
    booking.destroy
    render json: { success: true }
  end

  def destroy
    @room = Room.find(params[:id])

    if @room.destroy
      flash[:notice] = 'La salle et toutes les images et réservations associées ont été supprimées avec succès.'
      redirect_to rooms_path
    else
      flash[:alert] = "Impossible de supprimer la salle."
      redirect_to rooms_path
    end
  end

  private

  def room_params
    params.require(:room).permit(
      :name, :description, :main_photo, :mail, :phone, :kitchen,
      :hourly_rate, :daily_rate, :weekly_rate, :monthly_rate, :weekend_rate,
      :quarterly_rate, :semiannual_rate, :annual_rate, :capacity, :surface,
      :address, :city, :department, additional_photos: []
    )
  end

  def ensure_bailleur
    unless current_user&.bailleur?
      redirect_to root_path, alert: "Vous devez être un bailleur pour effectuer cette action."
    end
  end

  def set_room
    @room = Room.find_by(id: params[:id])
    unless @room
      redirect_to rooms_path, alert: "Salle non trouvée."
    end
  end

  def ensure_owner
    redirect_to rooms_path, alert: "Vous n'avez pas les droits pour gérer cette salle." unless current_user.id == @room.user_id
  end

  def ensure_bailleur_or_correct_visibility
    redirect_to root_path, alert: "Accès non autorisé" unless room_visible_to_current_user?(@room)
  end

  def room_visible_to_current_user?(room)
    room.is_public || (user_signed_in? && (current_user.bailleur? || current_user.loueur?))
  end
end
