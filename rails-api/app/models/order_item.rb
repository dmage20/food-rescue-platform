class OrderItem < ApplicationRecord
  belongs_to :order

  validates :item_type, presence: true, inclusion: { in: %w[product bundle] }
  validates :item_id, :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_at_purchase, presence: true, numericality: { greater_than: 0 }

  def item
    case item_type
    when 'product'
      Product.find_by(id: item_id)
    when 'bundle'
      Bundle.find_by(id: item_id)
    end
  end

  def total_price
    price_at_purchase * quantity
  end
end
