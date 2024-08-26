class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # Utilisation de préfixes pour les énumérations afin d'éviter les conflits
  enum status: { pending: 'pending', confirmed: 'confirmed', canceled: 'canceled' }, _prefix: :status
  enum duration: { hour: 'hour', day: 'day', week: 'week', month: 'month', year: 'year' }, _prefix: :duration

  # Validations
  validates :start_date, :email, :phone, :address, presence: true
  validate :end_date_after_start_date, unless: -> { duration_hour? }
  validate :email_format
  validate :start_date_in_future
  validate :no_overlap_with_existing_bookings
  validate :duration_must_be_valid

  # Méthode pour calculer la date de fin en fonction de la durée
  def end_date
    return nil if start_date.nil?

    case duration
    when 'hour'
      hour_count = hour_count.present? ? hour_count : 1 # Valeur par défaut
      start_date + hour_count.hours
    when 'day'
      day_count = day_count.present? ? day_count : 1 # Valeur par défaut
      start_date + day_count.days
    when 'week'
      week_count = week_count.present? ? week_count : 1 # Valeur par défaut
      start_date + week_count.weeks
    when 'month'
      month_count = month_count.present? ? month_count : 1 # Valeur par défaut
      start_date + month_count.months
    when 'year'
      year_count = year_count.present? ? year_count : 1 # Valeur par défaut
      start_date + year_count.years
    else
      start_date
    end
  end

  private

  # Validation pour éviter les chevauchements avec les réservations existantes
  def no_overlap_with_existing_bookings
    overlapping_bookings = room.bookings.where.not(id: id)
                                        .where("start_date < ? AND end_date > ?", end_date, start_date)
    if overlapping_bookings.exists?
      Rails.logger.info "Chevauchement détecté avec les réservations suivantes : #{overlapping_bookings.pluck(:id)}"
      errors.add(:base, "Cette période chevauche une réservation existante")
    end
  end

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

  def duration_must_be_valid
    errors.add(:duration, "doit être spécifiée") if duration.nil?
  end
end
