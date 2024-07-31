class Room < ApplicationRecord
  belongs_to :user
  has_many :bookings
  has_many :reviews

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
end


  def available?(start_date, end_date)
    bookings.where('start_date <= ? AND end_date >= ?', end_date, start_date).none?
  end
end