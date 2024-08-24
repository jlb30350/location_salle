class Room < ApplicationRecord
  belongs_to :user
  has_many :availabilities
  has_many_attached :additional_photos
  has_one_attached :main_photo
  has_many :bookings
  has_many :reviews
  has_many :room_services
  has_many :services, through: :room_services

  # Validations de présence
  validates :name, :description, :capacity, :address, :city, :department, :surface, :mail, :phone, presence: true

  # Validation des formats et valeurs numériques
  validates :capacity, :surface, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :hourly_rate, :daily_rate, :weekly_rate, :monthly_rate, :weekend_rate,
            :quarterly_rate, :semiannual_rate, :annual_rate, numericality: { greater_than_or_equal_to: 0 }

  # Validation des photos
  validates :main_photo, presence: true, unless: -> { additional_photos.attached? }
  validates :additional_photos, presence: true, unless: -> { main_photo.attached? }

  validate :at_least_one_rate_present

  private

  def at_least_one_rate_present
    if [hourly_rate, daily_rate, weekly_rate, monthly_rate, weekend_rate, quarterly_rate, semiannual_rate, annual_rate].all?(&:blank?)
      errors.add(:base, "Au moins un tarif doit être défini.")
    end
  end
end
