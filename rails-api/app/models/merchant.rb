class Merchant < ApplicationRecord
  has_secure_password

  has_many :products, dependent: :destroy
  has_many :bundles, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :address, presence: true
  validates :latitude, :longitude, presence: true, numericality: true

  scope :nearby, ->(lat, lng, radius_km = 5) {
    where(
      "6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude))) <= ?",
      lat, lng, lat, radius_km
    )
  }

  def available_products
    products.where('available_quantity > 0').where('expires_at > ?', Time.current)
  end

  def available_bundles
    bundles.where('available_quantity > 0').where('expires_at > ?', Time.current)
  end
end
