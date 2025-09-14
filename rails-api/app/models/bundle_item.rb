class BundleItem < ApplicationRecord
  belongs_to :bundle
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :bundle_id, uniqueness: { scope: :product_id }
end
