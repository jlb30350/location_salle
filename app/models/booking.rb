class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # Énumérations pour le statut et la durée de la réservation
  enum status: { pending: 'pending', confirmed: 'confirmed', canceled: 'canceled' }, _prefix: :status
  enum duration: { hour: 0, day: 1, multiple_days: 2, weekend: 3, week: 4, month: 5, year: 6 }

  # Validations
  validates :first_name, :last_name, :email, presence: true
  validates :phone, format: { with: /\A\d{10}\z/, message: "doit être un numéro de téléphone valide (10 chiffres)" }
  validates :start_date, :end_date, presence: true
  validate :start_date_in_the_future
  validate :end_date_after_start_date
  validate :no_overlap_with_existing_bookings

  # Callbacks
  before_validation :set_end_date_based_on_duration

  # Méthode pour calculer la date de fin en fonction de la durée
  def calculate_end_date
    return start_date if start_date.nil?

    case duration
    when 'hour'
      start_date.change(hour: 17) # Fin de la journée à 17h
    when 'day'
      start_date.change(hour: 17) # Fin de la journée à 17h
    when 'multiple_days'
      start_date + 6.days
    when 'weekend'
      start_date + 1.day.change(hour: 17) # Samedi à 7h - Dimanche 17h
    when 'week'
      start_date + 6.days.change(hour: 17)
    when 'month'
      start_date + 1.month.change(hour: 17)
    when 'year'
      start_date + 1.year.change(hour: 17)
    else
      start_date
    end
  end

  # Méthode pour calculer le montant total de la réservation
  def total_amount
    case duration
    when 'hour'
      room.hourly_rate * number_of_hours
    when 'day'
      room.daily_rate * number_of_days
    when 'multiple_days'
      room.daily_rate * number_of_days
    when 'weekend'
      room.weekend_rate
    when 'week'
      room.weekly_rate
    when 'month'
      room.monthly_rate
    when 'year'
      room.annual_rate
    else
      0 # Valeur par défaut
    end
  end

  private

  # Calcul du nombre d'heures pour une réservation à l'heure
  def number_of_hours
    ((end_date - start_date) / 1.hour).to_i
  end

  # Calcul du nombre de jours pour une réservation
  def number_of_days
    (end_date.to_date - start_date.to_date).to_i + 1 # Ajout de 1 pour inclure le jour de début
  end

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

  # Validation pour s'assurer que la date de fin est après la date de début
  def end_date_after_start_date
    if start_date.present? && end_date.present? && end_date < start_date
      errors.add(:end_date, "doit être après la date de début")
    end
  end

  # Validation pour éviter les chevauchements avec les réservations existantes
  def no_overlap_with_existing_bookings
    overlapping_bookings = room.bookings.where.not(id: id)
                                        .where("start_date < ? AND end_date > ?", end_date, start_date)
    
    overlapping_bookings.each do |booking|
      if (start_date < booking.end_date && end_date > booking.start_date)
        errors.add(:base, "Cette période chevauche une réservation existante.")
        break
      end
    end
  end
end
