class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy, :delete_photo]
  before_action :ensure_owner, only: [:edit, :update, :destroy, :delete_photo]

  # Autres actions existantes (index, show, new, create, edit, update, destroy)

  def delete_photo
    @photo = @room.photos.find(params[:photo_id])
    @photo.purge
    redirect_to edit_room_path(@room), notice: 'Photo supprimée avec succès.'
  end

  private

  def room_params
    params.require(:room).permit(:name, :description, :capacity, :price, :address, photos: [])
  end

  def set_room
    @room = Room.find(params[:id])
  end

  def ensure_owner
    unless @room.user == current_user
      redirect_to root_path, alert: "Vous n'êtes pas autorisé à effectuer cette action."
    end
  end
end