class RoomsController < ApplicationController
  
  before_action :authenticate_user!, except: [:index, :show, :search]
  before_action :set_room, only: [:show, :edit, :update, :destroy, :delete_photo, :delete_additional_photo]
  
  # Actions spécifiques au bailleur
  before_action :ensure_bailleur, only: [:new, :create, :edit, :update, :destroy, :delete_photo, :delete_additional_photo]

  # Vérifie si l'utilisateur est propriétaire avant certaines actions
  before_action :ensure_owner, only: [:edit, :update, :destroy, :delete_photo, :delete_additional_photo]

  # Vérifie que l'utilisateur est soit bailleur, soit autorisé à voir la salle en fonction de sa visibilité
  before_action :ensure_bailleur_or_correct_visibility, only: [:show]

  # Ajoutez ici vos actions (index, show, new, create, edit, update, destroy)

  def index
    if user_signed_in? && current_user.bailleur?
      @rooms = current_user.rooms
    else
      @rooms = Room.where(is_public: true)
    end
  end

  def my_rooms
    @rooms = current_user.rooms.paginate(page: params[:page], per_page: 10)
    render :index
  end

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

      # Récupération des réservations pour le calendrier
      @bookings = @room.bookings.where('start_date >= ? AND end_date <= ?', Date.today.beginning_of_month, Date.today.end_of_month)
    else
      redirect_to rooms_path, alert: 'Salle non trouvée.'
    end
  end

  def new
    @room = Room.new
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
  
  def edit
  end

  def availability
    @room = Room.find(params[:id])
    @bookings = @room.bookings
  end

  def update
    @room = Room.find(params[:id])
    if @room.update(room_params)
      # Assurez-vous que les photos sont attachées correctement après la mise à jour
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

  def delete_photo
    photo = @room.main_photo
    if photo&.purge
      redirect_to edit_room_path(@room), notice: 'Photo supprimée avec succès.'
    else
      redirect_to edit_room_path(@room), alert: "La suppression de la photo a échoué."
    end
  end

  def delete_main_photo
    if @room.main_photo.attached?
      @room.main_photo.purge
      redirect_to edit_room_path(@room), notice: 'Photo principale supprimée avec succès.'
    else
      redirect_to edit_room_path(@room), alert: 'Aucune photo principale à supprimer.'
    end
  end

  def create_reservation
    @room = Room.find(params[:room_id])
    @booking = @room.bookings.new(user: current_user, start_date: params[:start_date], end_date: params[:end_date])
  
    if @booking.save
      redirect_to @room, notice: 'Réservation effectuée avec succès.'
    else
      redirect_to availability_room_path(@room), alert: 'Erreur lors de la réservation.'
    end
  end

  def delete_additional_photo
    photo = @room.additional_photos.find(params[:photo_id])
    if photo.present?
      photo.purge
      redirect_to edit_room_path(@room), notice: 'Photo supplémentaire supprimée avec succès.'
    else
      redirect_to edit_room_path(@room), alert: 'Aucune photo à supprimer.'
    end
  end

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
    # Autoriser l'accès si la salle est publique ou si l'utilisateur est un bailleur ou un loueur
    unless room_visible_to_current_user?(@room)
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end
  def room_visible_to_current_user?(room)
    room.is_public || (user_signed_in? && (current_user.bailleur? || current_user.loueur?))
  end
end
