class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # Validation des champs de réservation
  validates :first_name, :last_name, :email, presence: true
  validates :phone, format: { with: /\A\d{10}\z/, message: "doit être un numéro de téléphone valide (10 chiffres)" }
  validates :start_date, :end_date, presence: true
  validate :start_date_in_the_future
  validate :end_date_after_start_date
  validate :no_overlap_with_existing_bookings

  # Calcule automatiquement la durée basée sur les dates
  def calculated_duration
    days = (end_date - start_date).to_i

    case days
    when 0
      :hour
    when 1
      :day
    when 2..6
      :multiple_days
    when 7
      :week
    when 28..31
      :month
    when 90..92
      :quarter
    when 180..183
      :semiannual
    when 365
      :year
    else
      :custom_duration # Si c'est une durée personnalisée
    end
  end

  # Méthode pour calculer le montant total
  def total_amount
    case calculated_duration
    when :hour
      room.hourly_rate
    when :day
      room.daily_rate
    when :multiple_days
      room.daily_rate * (end_date - start_date).to_i
    when :week
      room.weekly_rate
    when :month
      room.monthly_rate
    when :quarter
      room.quarterly_rate
    when :semiannual
      room.semiannual_rate
    when :year
      room.annual_rate
    else
      0 # Cas par défaut si aucune durée n'est définie
    end
  end

  private

  # Validation pour vérifier que la date de début est dans le futur
  def start_date_in_the_future
    errors.add(:start_date, "ne peut pas être dans le passé") if start_date.present? && start_date < Date.today
  end

  # Validation pour s'assurer que la date de fin est après la date de début
  def end_date_after_start_date
    errors.add(:end_date, "doit être après la date de début") if start_date.present? && end_date.present? && end_date < start_date
  end

  # Validation pour éviter les chevauchements avec les réservations existantes
  def no_overlap_with_existing_bookings
    return unless start_date.present? && end_date.present?

    overlapping_bookings = Booking.where(room_id: room_id)
                                  .where.not(id: id) # Exclure la réservation courante lors de la vérification
                                  .where("start_date < ? AND end_date > ?", end_date, start_date)

    if overlapping_bookings.exists?
      errors.add(:base, "Les dates sélectionnées chevauchent une réservation existante.")
    end
  end
end
