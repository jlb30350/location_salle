class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  enum status: { pending: 'pending', confirmed: 'confirmed', canceled: 'canceled' }, _prefix: :status
  enum duration: { hour: 0, day: 1, multiple_days: 2, weekend: 3, week: 4, month: 5, year: 6 }

  # Validations
  validates :first_name, :last_name, :email, presence: true
  validates :phone, format: { with: /\A\d{10}\z/, message: "doit être un numéro de téléphone valide (10 chiffres)" }
  
  validate :start_date_in_the_future
  validate :no_overlap_with_existing_bookings
  
  before_validation :set_end_date_based_on_duration
  
  # Méthode pour calculer la date de fin en fonction de la durée
  def calculate_end_date
    return start_date if start_date.nil?

    case duration
    when 'day'
      start_date
    when 'multiple_days'
      start_date + 6.days
    when 'week'
      start_date + 7.days
    when 'month'
      start_date + 1.month
    when 'year'
      start_date + 1.year
    else
      start_date
    end
  end

  private

  # Avant validation, calculer la date de fin basée sur la durée
  def set_end_date_based_on_duration
    self.end_date = calculate_end_date if start_date.present? && end_date.nil?
  end

  # Validation pour s'assurer que la date de début est dans le futur
  def start_date_in_the_future
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "ne peut pas être dans le passé")
    end
  end

  # Validation pour éviter les chevauchements avec les réservations existantes
  def no_overlap_with_existing_bookings
    overlapping_bookings = room.bookings.where.not(id: id)
                                         .where("start_date < ? AND end_date > ?", end_date, start_date)
    if overlapping_bookings.exists?
      errors.add(:base, "Cette période chevauche une réservation existante.")
    end
  end
end
