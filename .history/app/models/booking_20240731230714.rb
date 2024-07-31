# app/models/booking.rb
class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_one :review

  validates :start_date, :end_date, presence: true
end



