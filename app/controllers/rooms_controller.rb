class RoomsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_room, only: [:show, :edit, :update, :destroy, :delete_photo]
  before_action :ensure_bailleur, only: [:new, :create, :edit, :update, :destroy, :delete_photo]
  before_action :ensure_owner, only: [:edit, :update, :destroy, :delete_photo]

  def index
    @rooms = Room.paginate(page: params[:page], per_page: 10)
  end

  def show
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
  end

  def update
    if @room.update(room_params)
      redirect_to @room, notice: 'Salle mise à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    @room.destroy
    redirect_to rooms_url, notice: 'Salle supprimée avec succès.'
  end

  def delete_photo
    @photo = @room.photos.find(params[:photo_id])
    @photo.purge
    redirect_to edit_room_path(@room), notice: 'Photo supprimée avec succès.'
  end

  def search
    query = params[:query]
    if query.present?
      if query.match?(/^\d{5}$/)
        @rooms = Room.where(department: query)
      else
        @rooms = Room.where("LOWER(city) LIKE ?", "%#{query.downcase}%")
      end
    else
      @rooms = Room.none
    end
    render :search
  end

  private

  def room_params
    params.require(:room).permit(:name, :description, :capacity, :price, :address, :city, :department, photos: [])
  end

  def set_room
    @room = Room.find(params[:id])
  end

  def ensure_bailleur
    unless current_user.bailleur?
      redirect_to root_path, alert: "Seuls les bailleurs peuvent gérer les salles."
    end
  end

  def ensure_owner
    unless @room.user == current_user
      redirect_to root_path, alert: "Vous n'êtes pas autorisé à effectuer cette action."
    end
  end
end
