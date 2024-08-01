# app/models/service.rb
class Service < ApplicationRecord
     has_and_belongs_to_many :rooms
    has_many :room_services
    has_many :rooms, through: :room_services
    validates :name, presence: true, uniqueness: true
    validates :description, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  end