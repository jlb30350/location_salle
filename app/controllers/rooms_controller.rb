class RoomsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  before_action :set_room, only: [:show, :edit, :update, :destroy, :delete_photo]
  before_action :ensure_bailleur, only: [:new, :create, :edit, :update, :destroy, :delete_photo]
  before_action :ensure_owner, only: [:edit, :update, :destroy, :delete_photo]
  before_action :ensure_bailleur_or_correct_visibility, only: [:show]

  # app/controllers/rooms_controller.rb
def index
  if user_signed_in? && current_user.bailleur?
    @rooms = current_user.rooms
  else
    @rooms = Room.where(is_public: true) # Cette ligne est exécutée si l'utilisateur n'est pas connecté ou n'est pas un bailleur
  end
end

  

  def my_rooms
    @rooms = current_user.rooms.paginate(page: params[:page], per_page: 10)
    render :index
  end

  def show
    @room = Room.find(params[:id])
    # Supposons que le statut '1' représente une réservation confirmée
    @bookings = @room.bookings.where(status: 1)
  end
  

  def new
    @room = Room.new
  end

  def create
    @room = current_user.rooms.new(room_params)
    if @room.save
      redirect_to @room, notice: 'Salle ajoutée avec succès.'
    else
      render :new
    end
  end

  def edit
    # Code optionnel pour l'édition
  end

  def update
    if @room.update(room_params)
      redirect_to @room, notice: 'Salle mise à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    if @room.destroy
      redirect_to rooms_url, notice: 'La salle a été supprimée avec succès.'
    else
      redirect_to @room, alert: "La suppression de la salle a échoué."
    end
  end

  def delete_photo
    photo = @room.photos.find(params[:photo_id])
    if photo.purge
      redirect_to edit_room_path(@room), notice: 'Photo supprimée avec succès.'
    else
      redirect_to edit_room_path(@room), alert: "La suppression de la photo a échoué."
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
    params.require(:room).permit(:name, :description, :capacity, :address, :city, :department, :surface, :mail, :phone, :kitchen, :hourly_rate, :daily_rate, :weekly_rate, :monthly_rate, :weekend_rate, :quarterly_rate, :semiannual_rate, :annual_rate, photos: [])
  end

  def set_room
    @room = Room.find(params[:id])
    redirect_to rooms_path, alert: "Accès non autorisé" unless room_visible_to_current_user?(@room)
  end

  def ensure_bailleur_or_correct_visibility
    redirect_to root_path unless room_visible_to_current_user?(@room)
  end

  def room_visible_to_current_user?(room)
    room.is_public || (user_signed_in? && current_user.bailleur? && room.user_id == current_user.id)
  end
end
