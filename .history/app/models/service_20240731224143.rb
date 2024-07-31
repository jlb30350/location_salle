# app/models/service.rb
class Service < ApplicationRecord
    has_many :room_services
    has_many :rooms, through: :room_services
    validates :name, presence: true, uniqueness: true
    validates :description, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  end
  
  # app/models/room_service.rb
  class RoomService < ApplicationRecord
    belongs_to :room
    belongs_to :service
    validates :room_id, uniqueness: { scope: :service_id }
  end
  
  # app/controllers/room_services_controller.rb
  class RoomServicesController < ApplicationController
    before_action :set_room
  
    def index
      @room_services = @room.room_services.includes(:service)
      @available_services = Service.all - @room.services
    end
  
    def create
      @room_service = @room.room_services.build(service_id: params[:service_id])
      if @room_service.save
        redirect_to room_room_services_path(@room), notice: 'Service ajouté avec succès.'
      else
        redirect_to room_room_services_path(@room), alert: 'Erreur lors de l'ajout du service.'
      end
    end
  
    def destroy
      @room_service = @room.room_services.find_by(service_id: params[:id])
      @room_service.destroy
      redirect_to room_room_services_path(@room), notice: 'Service retiré avec succès.'
    end
  
    private
  
    def set_room
      @room = Room.find(params[:room_id])
    end
  end