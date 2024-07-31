# app/models/booking.rb
class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_one :review
end



