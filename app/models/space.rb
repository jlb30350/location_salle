class Space < ApplicationRecord
    belongs_to :user
    has_many :bookings
    has_many_attached :photos
  
    # Validations et autres configurations...
  end