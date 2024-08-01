class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: [:show, :edit, :update, :destroy, :delete_photo]
  before_action :ensure_bailleur, only: [ :new, :create, :edit, :update, :destroy, :delete_photo]

  # Autres actions existantes (index, show, new, create, edit, update, destroy)

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
        @rooms = Room.where("city ILIKE ?", "%#{query}%")
      end
    else
      @rooms = Room.none
    end
  
    render :search
  end


  private

  def room_params
    params.require(:room).permit(:name, :description, :capacity, :price, :address, photos: [])
  end

  def set_room
    @room = Room.find(params[:id])
  end

  def ensure_bailleur
    unless current_user.bailleur?
      redirect_to root_path, alert: "Seuls les bailleurs peuvent gérer les salles."
    end
  end
end