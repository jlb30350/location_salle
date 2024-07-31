# app/models/room.rb
class Room < ApplicationRecord
  belongs_to :user
  has_many :availabilities
  has_many_attached :photos

  validates :name, :description, :capacity, :price, :address, presence: true
end

# app/models/availability.rb
class Availability < ApplicationRecord
  belongs_to :room

  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  geocoded_by :address
  after_validation :geocode, if: :address_changed?


  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time < start_time
      errors.add(:end_time, "doit être après l'heure de début")
    end
  end
end