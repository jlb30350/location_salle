# app/models/review.rb
class Review < ApplicationRecord
  belongs_to :user
  belongs_to :room
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true
end

