class RoomsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search, :bookings]
  before_action :set_room, only: [:show, :edit, :update, :destroy, :delete_photo, :delete_additional_photo, :availability, :bookings]

  # Actions spécifiques au bailleur
  before_action :ensure_bailleur, only: [:new, :create, :edit, :update, :destroy, :delete_photo, :delete_additional_photo]

  # Vérifie si l'utilisateur est propriétaire avant certaines actions
  before_action :ensure_owner, only: [:edit, :update, :destroy, :delete_photo, :delete_additional_photo]

  # Vérifie que l'utilisateur est soit bailleur, soit autorisé à voir la salle en fonction de sa visibilité
  before_action :ensure_bailleur_or_correct_visibility, only: [:show]

  # Affiche la liste des salles
  def index
    @rooms = if user_signed_in? && current_user.bailleur?
               current_user.rooms
             else
               Room.where(is_public: true)
             end
  end

  # Affiche les salles de l'utilisateur
  def my_rooms
    @rooms = current_user.rooms.paginate(page: params[:page], per_page: 10)
    render :index
  end

  # Affiche une salle en détail
  def show
    if @room
      # Informations de base accessibles à tous
      @basic_info = {
        name: @room.name,
        city: @room.city,
        department: @room.department,
        capacity: @room.capacity
      }

      if user_signed_in?
        # Informations supplémentaires pour les utilisateurs connectés
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

      # Gestion des mois pour le calendrier
      @year = params[:year] ? params[:year].to_i : Date.today.year
      @month = params[:month] ? params[:month].to_i : Date.today.month

      first_day_of_month = Date.new(@year, @month, 1)
      last_day_of_month = first_day_of_month.end_of_month

      # Récupération des réservations pour le calendrier sur le mois affiché
      @bookings = @room.bookings.where('start_date <= ? AND end_date >= ?', last_day_of_month, first_day_of_month)
    else
      redirect_to rooms_path, alert: 'Salle non trouvée.'
    end
  end

  
  # Crée ou met à jour une réservation
  def create_or_update_booking
    booking = params[:id] ? Booking.find(params[:id]) : @room.bookings.new(user: current_user)
    booking.assign_attributes(start_date: params[:start_date], end_date: params[:end_date])

    if booking.save
      render json: { success: true }
    else
      render json: { success: false, errors: booking.errors.full_messages }
    end
  end

  def bookings
    @bookings = @room.bookings
    respond_to do |format|
      format.html # Rendu de la vue HTML par défaut
      format.json { render json: @bookings }
    end
  end
  
  def availability
    @year = params[:year] ? params[:year].to_i : Date.today.year
    @month = params[:month] ? params[:month].to_i : Date.today.month

    first_day_of_month = Date.new(@year, @month, 1)
    last_day_of_month = first_day_of_month.end_of_month

    @bookings = @room.bookings.where('start_date <= ? AND end_date >= ?', last_day_of_month, first_day_of_month)
    render :show
  end

  # Supprime une réservation
  def destroy_booking
    booking = Booking.find(params[:id])
    booking.destroy
    render json: { success: true }
  end

  # Action pour créer une nouvelle salle
  def new
    @room = Room.new
  end

  # Action pour enregistrer une nouvelle salle
  def create
    @room = current_user.rooms.new(room_params)
    if @room.save
      @room.additional_photos.attach(params[:room][:additional_photos]) if params[:room][:additional_photos].present?
      redirect_to @room, notice: 'Salle ajoutée avec succès.'
    else
      render :new
    end
  end

  # Action pour éditer une salle
  def edit
  end

  # Action pour mettre à jour une salle
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

  # Action pour supprimer une salle
  def destroy
    if @room.destroy
      redirect_to rooms_url, notice: 'La salle a été supprimée avec succès.'
    else
      redirect_to rooms_url, alert: "Impossible de supprimer la salle."
    end
  end

  # Action pour supprimer une photo principale
  def delete_photo
    if @room.main_photo&.purge
      redirect_to edit_room_path(@room), notice: 'Photo supprimée avec succès.'
    else
      redirect_to edit_room_path(@room), alert: "La suppression de la photo a échoué."
    end
  end

  # Action pour supprimer une photo supplémentaire
  def delete_additional_photo
    photo = @room.additional_photos.find(params[:photo_id])
    if photo.present?
      photo.purge
      redirect_to edit_room_path(@room), notice: 'Photo supplémentaire supprimée avec succès.'
    else
      redirect_to edit_room_path(@room), alert: 'Aucune photo à supprimer.'
    end
  end

  # Action pour rechercher des salles
  def search
    session[:search_query] = params[:query] if params[:query].present?
    @rooms = if params[:query].present?
               if params[:query].match?(/^\d{5}$/)
                 Room.where(department: params[:query])
               else
                 Room.where("LOWER(city) LIKE ?", "%#{params[:query].downcase}%")
               end
             else
               Room.none
             end
    render :search
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
    @room = Room.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to rooms_path, alert: "Salle non trouvée."
  end

  def ensure_owner
    redirect_to rooms_path, alert: "Vous n'avez pas les droits pour gérer cette salle." unless current_user.id == @room.user_id
  end

  def ensure_bailleur_or_correct_visibility
    unless room_visible_to_current_user?(@room)
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end

  def room_visible_to_current_user?(room)
    room.is_public || (user_signed_in? && (current_user.bailleur? || current_user.loueur?))
  end
end