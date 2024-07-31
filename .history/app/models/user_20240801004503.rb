# app/models/user.rb
class User < ApplicationRecord
  # Inclure les modules Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

    has_many :rooms
    has_many :bookings
    has_many :reviews

  # Supprimer has_secure_password si vous l'avez
  # include ActiveModel::SecurePassword
  # has_secure_password

  # Valider les attributs nécessaires
  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
end
