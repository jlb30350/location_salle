class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :space

  # Utilisation de préfixes pour les énumérations afin d'éviter les conflits
  enum status: { pending: 'pending', confirmed: 'confirmed', canceled: 'canceled' }, _prefix: :status
  enum duration: { hour: 'hour', day: 'day', week: 'week', month: 'month', year: 'year' }, _prefix: :duration

  # Validations
  validates :start_date, :duration, :email, :phone, :address, presence: true
  validates :start_time, presence: true, if: -> { duration_hour? }
  validates :hour_count, presence: true, numericality: { greater_than: 0 }, if: -> { duration_hour? }
  validates :day_count, presence: true, numericality: { greater_than: 0 }, if: -> { duration_day? }
  validates :week_count, presence: true, numericality: { greater_than: 0 }, if: -> { duration_week? }
  validates :month_count, presence: true, numericality: { greater_than: 0 }, if: -> { duration_month? }
  validates :year_count, presence: true, numericality: { greater_than: 0 }, if: -> { duration_year? }
  validate :end_date_after_start_date, unless: -> { duration_hour? }
  validate :email_format
  validate :start_date_in_future
  validate :no_overlap_with_existing_bookings

  # Scope pour les réservations confirmées
  scope :confirmed, -> { where(status: 'confirmed') }

  # Méthode pour calculer le montant total de la réservation en fonction de la durée
  def total_amount
    case duration
    when 'hour'
      space.calculate_price(:hour) * hour_count
    when 'day'
      space.calculate_price(:day) * day_count
    when 'week'
      space.calculate_price(:week) * week_count
    when 'month'
      space.calculate_price(:month) * month_count
    when 'year'
      space.calculate_price(:year) * year_count
    else
      0
    end
  end

  # Méthode pour calculer la date de fin en fonction de la durée
  def end_date
    return nil if start_date.nil?

    case duration
    when 'hour'
      start_date + hour_count.hours
    when 'day'
      start_date + day_count.days
    when 'week'
      start_date + week_count.weeks
    when 'month'
      start_date + month_count.months
    when 'year'
      start_date + year_count.years
    else
      start_date
    end
  end

  private

  # Validation pour s'assurer que la date de fin est après la date de début
  def end_date_after_start_date
    if end_date.nil? || start_date.nil? || end_date <= start_date
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
    overlapping_bookings = space.bookings.where.not(id: id)
                                        .where("start_date < ? AND end_date > ?", end_date, start_date)
    if overlapping_bookings.exists?
      errors.add(:base, "Cette période chevauche une réservation existante")
    end
  end
end
