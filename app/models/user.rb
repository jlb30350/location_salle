class User < ApplicationRecord
  # Définition de l'enum pour le rôle de l'utilisateur
  enum role: { loueur: 0, bailleur: 1 }

  # Associations
  has_many :rooms, dependent: :destroy
  has_many :bookings
  has_many :reviews

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
end
