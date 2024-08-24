# app/models/service.rb
class Service < ApplicationRecord
  has_many :room_services
  has_many :rooms, through: :room_services

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Supprimez ces validations si elles ne sont pas pertinentes pour un service
  # validates :surface, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # validates :capacity, presence: true, numericality: { greater_than: 0 }
end