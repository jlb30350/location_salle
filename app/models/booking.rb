class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  DURATIONS = %w[hour day multiple_days weekend week month quarter semiannual year]

  validates :duration, inclusion: { in: DURATIONS, message: "%{value} n'est pas une durée valide" }

  # Énumérations pour le statut et la durée de la réservation
  enum status: { pending: 'pending', confirmed: 'confirmed', canceled: 'canceled' }, _prefix: :status
  enum duration: { hour: 0, day: 1, multiple_days: 2, weekend: 3, week: 4, month: 5, quarter: 6, semiannual: 7, year: 8 }

  # Validations
  validates :first_name, :last_name, :email, presence: true
  validates :phone, format: { with: /\A\d{10}\z/, message: "doit être un numéro de téléphone valide (10 chiffres)" }
  validates :start_date, :end_date, presence: true
  validate :start_date_in_the_future
  validate :end_date_after_start_date
  validate :no_overlap_with_existing_bookings

  # Callbacks
  before_validation :set_end_date_based_on_duration

  # Méthode pour calculer le montant total
  def total_amount
    case duration
    when 'hour'
      room.hourly_rate
    when 'day'
      room.daily_rate
    when 'multiple_days'
      days = (end_date - start_date).to_i
      room.daily_rate * days
    when 'weekend'
      room.weekend_rate
    when 'week'
      room.weekly_rate
    when 'month'
      room.monthly_rate
    when 'quarter'
      room.quarterly_rate
    when 'semiannual'
      room.semiannual_rate
    when 'year'
      room.annual_rate
    else
      0 # Cas par défaut si aucune durée n'est définie
    end
  end

  private

  # Avant validation, calculer la date de fin basée sur la durée
  def set_end_date_based_on_duration
    self.end_date = calculate_end_date if start_date.present? && end_date.nil?
  end

  # Calculer la date de fin basée sur la durée
  def calculate_end_date
    case duration
    when 'hour'
      start_date + 1.hour
    when 'day'
      start_date + 1.day
    when 'multiple_days'
      start_date + 6.days # Maximum 6 jours
    when 'weekend'
      start_date + 2.days # Suppose que le week-end commence le samedi et se termine le dimanche
    when 'week'
      start_date + 1.week
    when 'month'
      start_date + 1.month
    when 'quarter'
      start_date + 3.months
    when 'semiannual'
      start_date + 6.months
    when 'year'
      start_date + 1.year
    else
      start_date
    end
  end

  # Validation pour s'assurer que la date de début est dans le futur
  def start_date_in_the_future
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "ne peut pas être dans le passé")
    end
  end

  # Validation pour s'assurer que la date de fin est après la date de début
  def end_date_after_start_date
    if start_date.present? && end_date.present? && end_date < start_date
      errors.add(:end_date, "doit être après la date de début")
    end
  end

  # Validation pour éviter les chevauchements avec les réservations existantes
  def no_overlap_with_existing_bookings
    if start_date.present? && end_date.present?
      overlapping_bookings = Booking.where(room_id: room_id)
                                    .where("start_date < ? AND end_date > ?", end_date, start_date)

      if overlapping_bookings.exists?
        errors.add(:base, "Les dates sélectionnées chevauchent une réservation existante.")
      end
    end
  end
end
