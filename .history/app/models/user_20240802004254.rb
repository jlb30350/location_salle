# app/models/user.rb
class User < ApplicationRecord



  enum role: { client: 0, bailleur: 1}
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
 

    has_many :rooms, dependent: :destroy
    has_many :bookings
    has_many :reviews

  # Supprimer has_secure_password si vous l'avez
  # include ActiveModel::SecurePassword
  # has_secure_password

  # Valider les attributs nécessaires
  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
end
