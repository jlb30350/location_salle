class Availability < ApplicationRecord
    belongs_to :room
  
    validates :start_time, :end_time, presence: true
  end
  