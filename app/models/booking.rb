class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # Utilisation de préfixes pour les énumérations afin d'éviter les conflits
  enum status: { pending: 'pending', confirmed: 'confirmed', canceled: 'canceled' }, _prefix: :status
  enum duration: { hour: 'hour', day: 'day', week: 'week', month: 'month', year: 'year' }, _prefix: :duration

  # Validations
  validates :start_date, :email, :phone, :address, presence: true
  validate :end_date_after_start_date, unless: -> { duration == 'hour' }
  validate :email_format
  validate :start_date_in_future
  validate :no_overlap_with_existing_bookings
  validate :validate_duration_presence

  # Méthode pour calculer la date de fin en fonction de la durée
  def end_date
    return nil if start_date.nil?
  
    case duration
    when 'hour'
      hour_count ||= 1  # Utiliser 1 heure par défaut
      start_date + hour_count.hours
    when 'day'
      day_count ||= 1  # Utiliser 1 jour par défaut
      start_date + day_count.days
    when 'week'
      week_count ||= 1  # Utiliser 1 semaine par défaut
      start_date + week_count.weeks
    when 'month'
      month_count ||= 1  # Utiliser 1 mois par défaut
      start_date + month_count.months
    when 'year'
      year_count ||= 1  # Utiliser 1 an par défaut
      start_date + year_count.years
    else
      start_date
    end
  end
  
  # Méthode pour calculer le montant total de la réservation en fonction de la durée
  def total_amount
    return 0 if room.nil? || duration.nil?

    case duration
    when 'hour'
      room.hourly_rate * (hour_count || 1)  # Utiliser 1 heure par défaut si `hour_count` est nil
    when 'day'
      room.daily_rate * (day_count || 1)  # Utiliser 1 jour par défaut si `day_count` est nil
    when 'week'
      room.weekly_rate * (week_count || 1)  # Utiliser 1 semaine par défaut si `week_count` est nil
    when 'month'
      room.monthly_rate * (month_count || 1)  # Utiliser 1 mois par défaut si `month_count` est nil
    when 'year'
      room.yearly_rate * (year_count || 1)  # Utiliser 1 an par défaut si `year_count` est nil
    else
      0  # Retourner 0 si la durée n'est pas reconnue
    end
  end

  private

  # Validation pour s'assurer que la date de fin est après la date de début
  def end_date_after_start_date
    if end_date.nil? || end_date <= start_date
      errors.add(:end_date, "doit être après la date de début")
    end
  end

  # Validation du format de l'email
  def email_format
    unless email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
      errors.add(:email, "n'est pas dans un format valide")
    end
  end

  # Validation pour s'assurer que la date de début est dans le futur
  def start_date_in_future
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "doit être dans le futur")
    end
  end

  # Validation pour éviter les chevauchements avec les réservations existantes
  def no_overlap_with_existing_bookings
    overlapping_bookings = room.bookings.where.not(id: id)
                                         .where("start_date < ? AND end_date > ?", end_date, start_date)
    if overlapping_bookings.exists?
      errors.add(:base, "Cette période chevauche une réservation existante")
    end
  end

  def validate_duration_presence
    errors.add(:duration, "doit être spécifiée") if duration.blank?
  end
end
