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
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "doit être une adresse e-mail valide" }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true

  # Callback pour définir le rôle par défaut
  before_validation :set_default_role, on: :create

  private

  def set_default_role
    self.role ||= :loueur
  end
end
