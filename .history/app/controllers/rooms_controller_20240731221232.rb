class RoomsController < ApplicationController
  def index
    @rooms = Room.all
  end

  def show
    @room = Room.find(params[:id])
    @booking = Booking.new
  end

  def new
    @room = Room.new
  end

  def create
    @room = current_user.rooms.build(room_params)
    if @room.save
      redirect_to @room, notice: 'Salle créée avec succès.'
    else
      render :new
    end
  end

  private

  def room_params
    params.require(:room).permit(:name, :description, :capacity, :price)
  end
end