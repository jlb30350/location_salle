# app/controllers/rooms_controller.rb
class RoomsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_room, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner, only: [:edit, :update, :destroy]

  def new
    @room = current_user.rooms.build
  end

  def search
    query = params[:query]
    
    if query.present?
      # Vérifiez si la requête est un code postal (5 chiffres)
      if query.match?(/^\d{5}$/)
        @spaces = Space.where(department: query)
      else
        # Sinon, recherchez par nom de ville
        @spaces = Space.where("city ILIKE ?", "%#{query}%")
      end
    else
      @spaces = Space.none
    end
  
    render :search
  end



  def create
    @room = current_user.rooms.build(room_params)
    if @room.save
      redirect_to landlord_dashboard_path, notice: 'Salle ajoutée avec succès.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @room.update(room_params)
      redirect_to landlord_dashboard_path, notice: 'Salle mise à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    @room.destroy
    redirect_to landlord_dashboard_path, notice: 'Salle supprimée avec succès.'
  end

# app/controllers/rooms_controller.rb
def delete_photo
  @room = Room.find(params[:id])
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