# app/models/service.rb
class Service < ApplicationRecord
    has_and_belongs_to_many :rooms
  end
  
  # app/controllers/services_controller.rb
  class ServicesController < ApplicationController
    def index
      @room = Room.find(params[:room_id])
      @available_services = Service.all - @room.services
    end
  
    def add_to_room
      @room = Room.find(params[:room_id])
      @service = Service.find(params[:service_id])
      @room.services << @service
      redirect_to @room, notice: 'Service ajouté avec succès.'
    end
  end