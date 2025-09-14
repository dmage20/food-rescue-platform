class Product < ApplicationRecord
  belongs_to :merchant
  has_many :bundle_items, dependent: :destroy
  has_many :bundles, through: :bundle_items

  validates :name, presence: true
  validates :category, presence: true
  validates :original_price, :discounted_price, presence: true, numericality: { greater_than: 0 }
  validates :discount_percentage, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 99 }
  validates :available_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :expires_at, presence: true
  validate :discounted_price_less_than_original
  validate :expires_at_in_future

  scope :available, -> { where('available_quantity > 0').where('expires_at > ?', Time.current) }
  scope :by_category, ->(category) { where(category: category) }
  scope :expiring_soon, ->(hours = 2) { where('expires_at <= ?', hours.hours.from_now) }

  def discount_amount
    original_price - discounted_price
  end

  def expired?
    expires_at <= Time.current
  end

  def available?
    available_quantity > 0 && !expired?
  end

  private

  def discounted_price_less_than_original
    return unless original_price && discounted_price

    errors.add(:discounted_price, 'must be less than original price') if discounted_price >= original_price
  end

  def expires_at_in_future
    return unless expires_at

    errors.add(:expires_at, 'must be in the future') if expires_at <= Time.current
  end
end
