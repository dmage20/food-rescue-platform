class Customer < ApplicationRecord
  has_secure_password

  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :preferred_radius, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 50 }

  def allergies
    dietary_preferences&.dig('allergies') || []
  end

  def preferences
    dietary_preferences&.dig('preferences') || []
  end

  def avoid
    dietary_preferences&.dig('avoid') || []
  end
end
