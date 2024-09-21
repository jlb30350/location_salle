class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # Validation des champs de réservation
  validates :first_name, :last_name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "doit être une adresse e-mail valide" }
  validates :phone, format: { with: /\A\d{10}\z/, message: "doit être un numéro de téléphone valide (10 chiffres)" }
  validates :start_date, :end_date, :start_time, :end_time, presence: true

  validate :start_date_in_the_future
  validate :end_date_after_start_date
  validate :no_overlap_with_existing_bookings
  validate :room_rates_present

  # Calculer le montant total avant validation
  before_validation :calculate_total_amount

  def calculate_total_amount
    if start_date && end_date && start_time && end_time
      self.total_amount = total_amount_calculated
      Rails.logger.debug "Montant total mis à jour : #{self.total_amount}"
    else
      errors.add(:base, "Impossible de calculer le montant total : dates ou heures manquantes.")
    end
  end

  def total_amount_calculated
    Rails.logger.debug "Calcul de total_amount pour la réservation ID: #{id}, durée: #{calculated_duration}"

    case calculated_duration
    when :hour
      room.hourly_rate
    when :day
      room.daily_rate
    when :multiple_days
      room.multiple_days_rate * (end_date - start_date + 1).to_i
    when :week
      room.weekly_rate
    when :month
      room.monthly_rate
    when :weekend
      room.weekend_rate
    when :quarter
      room.quarterly_rate
    when :semiannual
      room.semiannual_rate
    when :year
      room.annual_rate
    else
      0 # Valeur par défaut si la durée est inconnue ou non applicable
    end
  end

  def calculated_duration
    return nil if start_date.nil? || end_date.nil?

    days = (end_date - start_date).to_i
    return :hour if days == 0
    return :day if days == 1
    return :multiple_days if days > 1 && days < 7
    return :week if days == 7
    return :month if days >= 28 && days <= 31
    return :weekend if days == 2 && [5, 6].include?(start_date.wday)
    return :quarter if days >= 90 && days <= 92
    return :semiannual if days >= 180 && days <= 183
    return :year if days == 365
  end

  private

  # Valider que la date de début est dans le futur
  def start_date_in_the_future
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "ne peut pas être dans le passé")
    end
  end

  # Valider que la date de fin est après la date de début
  def end_date_after_start_date
    if start_date.present? && end_date.present?
      # Vérifie si c'est une réservation horaire
      if start_date == end_date && start_time >= end_time
        errors.add(:end_time, "L'heure de fin doit être après l'heure de début pour une réservation horaire.")
      elsif end_date < start_date
        errors.add(:end_date, "doit être après la date de début")
      end
    end
  end

  # Vérifier s'il y a des réservations chevauchantes
  def no_overlap_with_existing_bookings
    overlapping_bookings = room.bookings.where.not(id: self.id)
                                        .where('start_date < ? AND end_date > ?', self.end_date, self.start_date)

    if overlapping_bookings.exists?
      errors.add(:base, 'Cette réservation chevauche une autre réservation existante.')
    end
  end

  # Vérifier que les tarifs de la salle sont bien définis
  def room_rates_present
    if room.hourly_rate.nil? && room.daily_rate.nil? && room.weekly_rate.nil? && room.monthly_rate.nil?
      errors.add(:room, "Les tarifs de location ne sont pas définis.")
    end
  end
end
