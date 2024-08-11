class Review < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # Validations
  validates :content, presence: true
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  # Callbacks (si vous en avez)
  # before_save :some_method

  # Méthodes d'instance ou de classe
  def some_method
    # logique ici
  end
end
