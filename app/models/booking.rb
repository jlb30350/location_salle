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

  # Assure que le montant total est calculé avant la sauvegarde
  before_save :calculate_total_amount

  # Méthode publique pour recalculer le montant total
  def calculate_total_amount
    self.total_amount = total_amount # Utilisation de la méthode publique ici
    Rails.logger.debug "Montant total mis à jour : #{self.total_amount}" # Log du montant total après calcul
  end

  # Méthode publique pour calculer le montant total
  def total_amount
    Rails.logger.debug "Calcul de total_amount pour la réservation ID: #{id}, durée: #{calculated_duration}"  # Log de l'ID et de la durée

    amount = case calculated_duration
    when :hour
      room.hourly_rate || 0
    when :day
      room.daily_rate || 0
    when :multiple_days
      days = (end_date - start_date).to_i + 1
      room.daily_rate * days || 0
    when :week
      room.weekly_rate || 0
    when :month
      room.monthly_rate || 0
    when :quarter
      room.quarterly_rate || 0
    when :semiannual
      room.semiannual_rate || 0
    when :year
      room.annual_rate || 0
    else
      0 # Cas par défaut si aucune durée n'est définie
    end

    Rails.logger.debug "Montant calculé : #{amount}"  # Log du montant
    amount
  end

  # Calcule automatiquement la durée basée sur les dates
  def calculated_duration
    days = (end_date - start_date).to_i + 1  # Inclure le dernier jour
    Rails.logger.debug "Durée calculée en jours : #{days}"  # Log de la durée
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

  private

  # Validation pour vérifier que la date de début est dans le futur
  def start_date_in_the_future
    errors.add(:start_date, "ne peut pas être dans le passé") if start_date.present? && start_date < Date.today
  end

  # Validation pour s'assurer que la date de fin est après la date de début
  def end_date_after_start_date
    errors.add(:end_date, "doit être après la date de début") if start_date.present? && end_date.present? && end_date <= start_date
  end

  # Validation pour éviter les chevauchements avec les réservations existantes
  def no_overlap_with_existing_bookings
    return unless start_date.present? && end_date.present?

    overlapping_bookings = Booking.where(room_id: room_id)
                                  .where.not(id: id)
                                  .where("start_date < ? AND end_date > ?", end_date, start_date)

    errors.add(:base, "Les dates sélectionnées chevauchent une réservation existante.") if overlapping_bookings.exists?
  end
end
