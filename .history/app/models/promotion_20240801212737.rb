# app/models/promotion.rb
class Promotion < ApplicationRecord
    belongs_to :room
    validates :discount_percentage, presence: true, inclusion: { in: 1..100 }
    validates :start_date, :end_date, presence: true
    validate :end_date_after_start_date
    validate :no_overlapping_promotions
  
    scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.today, Date.today) }
  
    def active?
      start_date <= Date.today && end_date >= Date.today
    end
  
    private
  
    def end_date_after_start_date
      return if end_date.blank? || start_date.blank?
  
      if end_date < start_date
        errors.add(:end_date, "doit être après la date de début")
      end
    end
  
    def no_overlapping_promotions
      overlapping_promotions = room.promotions.where('(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?)', start_date, start_date, end_date, end_date)
      if overlapping_promotions.exists?
        errors.add(:base, "Il existe déjà une promotion pour cette période")
      end
    end
  end
  
  