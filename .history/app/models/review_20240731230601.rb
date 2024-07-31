## app/models/review.rb
class Review < ApplicationRecord
  belongs_to :booking
  has_one :user, through: :booking
  has_one :room, through: :booking

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true
  validate :booking_completed

  private

  def booking_completed
    errors.add(:booking, "doit être terminé pour laisser un avis") unless booking.end_date < Date.today
  end
end