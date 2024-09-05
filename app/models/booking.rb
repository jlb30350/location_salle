class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  enum status: { pending: 'pending', confirmed: 'confirmed', canceled: 'canceled' }, _prefix: :status
  enum duration: { hour: 0, day: 1, multiple_days: 2, weekend: 3, week: 4, month: 5, year: 6 }


  validate :validate_end_date_based_on_duration
  validate :start_date_in_future
  validate :no_overlap_with_existing_bookings
  validates :first_name, :last_name, :email, :phone, :start_date, :end_date, presence: true


  # Méthode pour calculer la date de fin en fonction de la durée
  def calculate_end_date
    return start_date if start_date.nil?
  
    case duration
    when 'one_day'
      start_date
    when 'multiple_days'
      start_date + 6.days
    when 'week'
      start_date + 7.days
    when 'month'
      start_date + 1.month
    else
      start_date
    end
  end
  

  private

  # Validation pour s'assurer que la date de fin est correcte en fonction de la durée
  def validate_end_date_based_on_duration
    computed_end_date = calculate_end_date
    Rails.logger.debug "Expected end date: #{computed_end_date}, Actual end date: #{end_date}"
    if end_date != computed_end_date
      errors.add(:end_date, "doit correspondre à la durée sélectionnée.")
    end
  end
  
  # Validation pour s'assurer que la date de début est dans le futur
  def start_date_in_future
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "ne peut pas être dans le passé")
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
