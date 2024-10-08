class Room < ApplicationRecord
  belongs_to :user
  has_many :availabilities
  has_many_attached :additional_photos
  has_one_attached :main_photo
  has_many :bookings, dependent: :destroy
  has_many :reviews
  has_many :room_services
  has_many :services, through: :room_services

  # Assumer les associations d'Active Storage
  has_one_attached :main_photo, dependent: :purge_later
  has_many_attached :additional_photos, dependent: :purge_later

  # Validations de présence
  validates :name, :description, :capacity, :address, :city, :department, :surface, :mail, :phone, presence: true

  # Validation des formats et valeurs numériques
  validates :capacity, :surface, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  # Validation des tarifs
  validates :hourly_rate, :daily_rate, :weekly_rate, :monthly_rate, :weekend_rate,
            :quarterly_rate, :semiannual_rate, :annual_rate, :multiple_days_rate, presence: true,
            numericality: { greater_than_or_equal_to: 0, message: "doit être supérieur ou égal à 0" }, allow_nil: true

  # Validation des photos
  validates :main_photo, presence: true, unless: -> { additional_photos.attached? }
  validates :additional_photos, presence: true, unless: -> { main_photo.attached? }

  validate :at_least_one_rate_present

  # Méthodes pour récupérer les tarifs avec des valeurs par défaut (si souhaité)
  def hourly_rate
    self[:hourly_rate] || 0
  end

  def daily_rate
    self[:daily_rate] || 0
  end

  def multiple_days_rate
    self[:multiple_days_rate] || 0
  end

  def weekly_rate
    self[:weekly_rate] || 0
  end

  def monthly_rate
    self[:monthly_rate] || 0
  end

  def weekend_rate
    self[:weekend_rate] || 100  # Utilise 100 comme tarif par défaut si aucun autre tarif n'est défini
  end

  def quarterly_rate
    self[:quarterly_rate] || 0
  end

  def semiannual_rate
    self[:semiannual_rate] || 0
  end

  def annual_rate
    self[:annual_rate] || 0
  end

  private

  # S'assurer qu'au moins un tarif est présent
  def at_least_one_rate_present
    if [hourly_rate, daily_rate, weekly_rate, monthly_rate, weekend_rate, multiple_days_rate, quarterly_rate, semiannual_rate, annual_rate].all? { |rate| rate == 0 }
      errors.add(:base, "Au moins un tarif doit être défini.")
    end
  end
end
