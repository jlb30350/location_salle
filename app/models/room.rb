# app/models/room.rb
class Room < ApplicationRecord
  belongs_to :user
  has_many :availabilities
  has_many_attached :photos
  has_many :bookings
  has_many :reviews

  validates :name, presence: true
  validates :description, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :address, presence: true
  validates :city, presence: true
  validates :department, presence: true
  validates :surface, presence: true
  validates :mail, presence: true
  validates :phone, presence: true
  validates :kitchen, presence: true
end

