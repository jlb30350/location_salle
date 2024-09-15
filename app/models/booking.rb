class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # Validation des champs de réservation
  validates :first_name, :last_name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "doit être une adresse e-mail valide" }
  validates :phone, format: { with: /\A\d{10}\z/, message: "doit être un numéro de téléphone valide (10 chiffres)" }
  validates :start_date, :end_date, presence: true
  validate :start_date_in_the_future
  validate :end_date_after_start_date
  validate :no_overlap_with_existing_bookings
  validate :room_rates_present

  # Calculer le montant total avant validation
  before_validation :calculate_total_amount

  # Recalculer le montant total
  def calculate_total_amount
    # Si les dates sont manquantes, le montant total ne peut pas être calculé
    if start_date.nil? || end_date.nil?
      Rails.logger.debug "Impossible de calculer le montant total : dates manquantes."
      self.total_amount = 0
      return
    end

    # Calcul du montant total en fonction de la durée
    self.total_amount = total_amount_calculated
    Rails.logger.debug "Montant total mis à jour : #{self.total_amount}" 
  end

  # Calcul du montant total en fonction de la durée
  def total_amount_calculated
    Rails.logger.debug "Calcul de total_amount pour la réservation ID: #{id}, durée: #{calculated_duration}"

    # Calculer le montant basé sur la durée déterminée
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

  # Méthode pour déterminer la durée de la réservation
  def calculated_duration
    # Vérifier que les dates existent avant de calculer la durée
    if start_date.nil? || end_date.nil?
      Rails.logger.debug "Durée impossible à calculer : dates manquantes."
      return nil
    end

    # Calculer la différence en jours
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

  # Vérifie que la date de début est dans le futur
  def start_date_in_the_future
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "ne peut pas être dans le passé")
    end
  end

  # Vérifie que la date de fin est après la date de début
  def end_date_after_start_date
    if start_date.present? && end_date.present? && end_date <= start_date
      errors.add(:end_date, "doit être après la date de début")
    end
  end

  # Vérifie l'absence de chevauchements avec les réservations existantes
  def no_overlap_with_existing_bookings
    return unless start_date.present? && end_date.present?

    overlapping_bookings = Booking.where(room_id: room_id)
                                  .where.not(id: id)
                                  .where("start_date < ? AND end_date > ?", end_date, start_date)

    if overlapping_bookings.exists?
      errors.add(:base, "Les dates sélectionnées chevauchent une réservation existante.")
    end
  end

  # S'assurer que les tarifs de la salle sont présents
  def room_rates_present
    if room.hourly_rate.nil? && room.daily_rate.nil? && room.weekly_rate.nil? && room.monthly_rate.nil?
      errors.add(:room, "Les tarifs de location ne sont pas définis.")
    end
  end
end
