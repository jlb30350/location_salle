class RoomsController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show, :search]
  before_action :ensure_bailleur, only: [:new, :create, :edit, :update, :destroy, :delete_photo]
  before_action :set_room, only: [:show, :edit, :update, :destroy, :delete_photo]
  before_action :ensure_owner, only: [:edit, :update, :destroy, :delete_photo]
  before_action :ensure_bailleur_or_correct_visibility, only: [:show]

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
    @room = Room.find(params[:id])
    @bookings = @room.bookings.where(status: 1)
  end

  def show_photo
    @room = Room.find(params[:room_id])
    @photo = @room.photos.find(params[:id])
    send_data @photo.download, type: @photo.content_type, disposition: 'inline'
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

  def ensure_bailleur
    unless current_user&.bailleur?
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end

  def set_room
    @room = Room.find(params[:id])
    unless room_visible_to_current_user?(@room)
      redirect_to rooms_path, alert: "Accès non autorisé"
    end
  end

  def ensure_owner
    @room = Room.find(params[:id])  # Assurez-vous que la salle est chargée
    unless current_user.id == @room.user_id
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end
  


  def ensure_bailleur_or_correct_visibility
    unless room_visible_to_current_user?(@room)
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end

  def room_visible_to_current_user?(room)
    room.is_public || (user_signed_in? && current_user.bailleur? && room.user_id == current_user.id)
  end

  def some_private_method
    # Logique de la méthode...
  end
end 
