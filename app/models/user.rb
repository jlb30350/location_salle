class User < ApplicationRecord
  # Enum pour le rôle de l'utilisateur
  enum role: { loueur: 0, bailleur: 1 }

  # Associations
  has_many :rooms, dependent: :destroy
  has_many :bookings
  has_many :reviews

  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :address, presence: false # Validation pour l'adresse ajoutée
end
