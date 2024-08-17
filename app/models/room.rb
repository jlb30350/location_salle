# app/models/room.rb
class Room < ApplicationRecord
  belongs_to :user
  has_many :availabilities
  has_many_attached :photos
  has_many :bookings
  has_many :reviews

  # Validations de présence
  validates :name, :description, :capacity, :price, :address, :city, :department, :surface, :mail, :phone, presence: true

  # Validations numériques
  validates :capacity, :surface, numericality: { greater_than_or_equal_to: 0 }
  validates :price, :hourly_rate, :daily_rate, :weekly_rate, :monthly_rate, :weekend_rate,
            :quarterly_rate, :semiannual_rate, :annual_rate, numericality: { greater_than_or_equal_to: 0 }

  # Validations spécifiques pour le téléphone et l'email
  validates :phone, format: { with: /\A\+?[0-9]{10,15}\z/, message: "doit être un numéro valide" }
  validates :mail, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "doit être une adresse email valide" }
end

