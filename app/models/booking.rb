class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  enum status: { pending: 'pending', confirmed: 'confirmed', canceled: 'canceled' }, _prefix: :status
  class Booking < ApplicationRecord
    enum duration: { hour: 0, day: 1, multiple_days: 2, weekend: 3, week: 4, month: 5, year: 6 }
  end
  


  validates :start_date, :email, :phone, :address, :duration, presence: true
  validate :validate_end_date_based_on_duration
  validate :start_date_in_future
  validate :no_overlap_with_existing_bookings

  # Méthode pour calculer la date de fin en fonction de la durée
  def calculate_end_date
    return start_date if start_date.nil?

    case duration
    when 'hour'
      start_date + 1.hour
    when 'day'
      start_date.end_of_day
    when 'week'
      start_date + 7.days
    when 'weekend'
      start_date + 2.days
    when 'month'
      start_date + 1.month
    else
      start_date # Default case, returns start_date if duration is not recognized
    end
  end

  # Validation pour vérifier si la date de fin correspond à la durée sélectionnée
  validate :validate_duration_and_dates


  private

  # Validation pour s'assurer que la date de fin est correcte en fonction de la durée
  def validate_end_date_based_on_duration
    computed_end_date = calculate_end_date
    if end_date != computed_end_date
      errors.add(:end_date, "doit correspondre à la durée sélectionnée.")
    end
  end

  # Validation pour s'assurer que la date de début est dans le futur
  def validate_duration_and_dates
    if duration == 'one_day' && start_date != end_date
      errors.add(:end_date, "doit être la même que la date de début pour une réservation d'un jour.")
    elsif duration == 'multiple_days' && (end_date - start_date).to_i > 6
      errors.add(:end_date, "ne peut pas être plus de 6 jours après la date de début pour une réservation de 2 à 6 jours.")
    end
  end


  # Validation pour éviter les chevauchements avec les réservations existantes
  def no_overlap_with_existing_bookings
    overlapping_bookings = room.bookings.where.not(id: id)
                                         .where("start_date < ? AND end_date > ?", calculate_end_date, start_date)
    if overlapping_bookings.exists?
      errors.add(:base, "Cette période chevauche une réservation existante.")
    end
  end
end
