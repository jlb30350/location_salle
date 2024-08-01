  # app/models/room_service.rb
  class RoomService < ApplicationRecord
    belongs_to :room
    belongs_to :service
    validates :room_id, uniqueness: { scope: :service_id }
  end