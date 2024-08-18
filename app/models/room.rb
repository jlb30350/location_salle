# app/models/room.rb
class Room < ApplicationRecord
  belongs_to :user
  has_many :availabilities
  has_many_attached :photos
  has_many :bookings
  has_many :reviews

  # Validations de présence
  validates :name, :description, :capacity, :address, :city, :department, :surface, :mail, :phone, presence: true

  # Validation du format de l'email
  validates :mail, format: { with: URI::MailTo::EMAIL_REGEXP, message: "doit être une adresse email valide" }
  
  # Validation du format du téléphone
  validates :phone, format: { with: /\A\+?[0-9]{10,15}\z/, message: "doit être un numéro valide" }
  
  # Validations numériques pour les champs de tarification et autres
  validates :capacity, :surface, numericality: { greater_than_or_equal_to: 0 }
  validates :hourly_rate, :daily_rate, :weekly_rate, :monthly_rate, :weekend_rate,
            :quarterly_rate, :semiannual_rate, :annual_rate, numericality: { greater_than_or_equal_to: 0, message: "doit être un nombre positif" }

  # Optionnel : Validation personnalisée pour s'assurer qu'au moins un des tarifs est défini
  validate :at_least_one_rate_present

  validate :check_photos_presence

  private

  def check_photos_presence
    if photos.blank?
      errors.add(:photos, "doivent être téléchargées.")
    end
  end


  def at_least_one_rate_present
    if [hourly_rate, daily_rate, weekly_rate, monthly_rate, weekend_rate, quarterly_rate, semiannual_rate, annual_rate].all?(&:zero?)
      errors.add(:base, "Au moins un tarif doit être défini")
    end
  end
end
