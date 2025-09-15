require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  let(:order_item) { build(:order_item) }

  describe 'associations' do
    it { should belong_to(:order) }

    context 'polymorphic item association' do
      let!(:merchant) { create(:merchant) }
      let!(:customer) { create(:customer) }
      let!(:order) { create(:order, customer: customer, merchant: merchant) }
      let!(:product) { create(:product, merchant: merchant) }
      let!(:bundle) { create(:bundle, merchant: merchant) }

      it 'can reference a product' do
        order_item = create(:order_item, :product_item, order: order, item_id: product.id)
        expect(order_item.item).to eq(product)
      end

      it 'can reference a bundle' do
        order_item = create(:order_item, :bundle_item, order: order, item_id: bundle.id)
        expect(order_item.item).to eq(bundle)
      end
    end
  end

  describe 'validations' do
    subject { order_item }

    it { should validate_presence_of(:item_type) }
    it { should validate_inclusion_of(:item_type).in_array(%w[product bundle]) }
    it { should validate_presence_of(:item_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_presence_of(:price_at_purchase) }
    it { should validate_numericality_of(:price_at_purchase).is_greater_than(0) }

    context 'item_type validation' do
      it 'accepts valid item types' do
        %w[product bundle].each do |type|
          order_item.item_type = type
          expect(order_item).to be_valid
        end
      end

      it 'rejects invalid item types' do
        ['service', 'invalid', '', nil].each do |type|
          order_item.item_type = type
          expect(order_item).not_to be_valid
        end
      end
    end

    context 'quantity validation' do
      it 'accepts positive quantities' do
        [1, 5, 100].each do |quantity|
          order_item.quantity = quantity
          expect(order_item).to be_valid
        end
      end

      it 'rejects zero quantity' do
        order_item.quantity = 0
        expect(order_item).not_to be_valid
        expect(order_item.errors[:quantity]).to include('must be greater than 0')
      end

      it 'rejects negative quantities' do
        order_item.quantity = -1
        expect(order_item).not_to be_valid
        expect(order_item.errors[:quantity]).to include('must be greater than 0')
      end

      it 'accepts decimal quantities if business allows' do
        order_item.quantity = 2.5
        expect(order_item).to be_valid # This depends on business requirements
      end
    end

    context 'price_at_purchase validation' do
      it 'accepts positive prices' do
        [0.01, 10.00, 999.99].each do |price|
          order_item.price_at_purchase = price
          expect(order_item).to be_valid
        end
      end

      it 'rejects zero or negative prices' do
        [0, -0.01, -10.00].each do |price|
          order_item.price_at_purchase = price
          expect(order_item).not_to be_valid
          expect(order_item.errors[:price_at_purchase]).to include('must be greater than 0')
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#item' do
      let!(:merchant) { create(:merchant) }
      let!(:customer) { create(:customer) }
      let!(:order) { create(:order, customer: customer, merchant: merchant) }

      context 'when item_type is product' do
        let!(:product) { create(:product, merchant: merchant, name: 'Fresh Bread') }
        let!(:order_item) { create(:order_item, order: order, item_type: 'product', item_id: product.id) }

        it 'returns the product' do
          expect(order_item.item).to eq(product)
          expect(order_item.item.name).to eq('Fresh Bread')
        end
      end

      context 'when item_type is bundle' do
        let!(:bundle) { create(:bundle, merchant: merchant, name: 'Breakfast Bundle') }
        let!(:order_item) { create(:order_item, order: order, item_type: 'bundle', item_id: bundle.id) }

        it 'returns the bundle' do
          expect(order_item.item).to eq(bundle)
          expect(order_item.item.name).to eq('Breakfast Bundle')
        end
      end

      context 'when referenced item does not exist' do
        let!(:order_item) { create(:order_item, order: order, item_type: 'product', item_id: 999999) }

        it 'returns nil' do
          expect(order_item.item).to be_nil
        end
      end

      context 'when item_type is invalid' do
        let!(:order_item) { build(:order_item, order: order, item_type: 'invalid') }

        it 'returns nil' do
          expect(order_item.item).to be_nil
        end
      end
    end

    describe '#total_price' do
      it 'calculates total price correctly' do
        order_item = build(:order_item, price_at_purchase: 12.50, quantity: 3)
        expect(order_item.total_price).to eq(37.50)
      end

      it 'handles decimal calculations' do
        order_item = build(:order_item, price_at_purchase: 3.33, quantity: 3)
        expect(order_item.total_price).to eq(9.99)
      end

      it 'handles single quantity' do
        order_item = build(:order_item, price_at_purchase: 15.75, quantity: 1)
        expect(order_item.total_price).to eq(15.75)
      end

      it 'handles large quantities' do
        order_item = build(:order_item, price_at_purchase: 0.50, quantity: 100)
        expect(order_item.total_price).to eq(50.00)
      end

      it 'handles decimal quantities if business allows' do
        order_item = build(:order_item, price_at_purchase: 10.00, quantity: 2.5)
        expect(order_item.total_price).to eq(25.00)
      end
    end
  end

  describe 'business logic scenarios' do
    let!(:merchant) { create(:merchant) }
    let!(:customer) { create(:customer) }
    let!(:order) { create(:order, customer: customer, merchant: merchant) }

    context 'product order items' do
      let!(:product) { create(:product, merchant: merchant, name: 'Organic Apples', discounted_price: 4.99) }

      it 'stores product information at time of purchase' do
        order_item = create(:order_item,
          order: order,
          item_type: 'product',
          item_id: product.id,
          name: product.name,
          price_at_purchase: product.discounted_price,
          quantity: 2
        )

        expect(order_item.name).to eq('Organic Apples')
        expect(order_item.price_at_purchase).to eq(4.99)
        expect(order_item.total_price).to eq(9.98)
      end

      it 'maintains historical price even if product price changes' do
        order_item = create(:order_item,
          order: order,
          item_type: 'product',
          item_id: product.id,
          name: product.name,
          price_at_purchase: 4.99,
          quantity: 1
        )

        # Product price changes after order
        product.update!(discounted_price: 6.99)

        expect(order_item.price_at_purchase).to eq(4.99) # Historical price preserved
        expect(product.discounted_price).to eq(6.99) # Current price updated
      end
    end

    context 'bundle order items' do
      let!(:bundle) { create(:bundle, merchant: merchant, name: 'Dinner Bundle', bundle_price: 24.99) }

      it 'stores bundle information at time of purchase' do
        order_item = create(:order_item,
          order: order,
          item_type: 'bundle',
          item_id: bundle.id,
          name: bundle.name,
          price_at_purchase: bundle.bundle_price,
          quantity: 1
        )

        expect(order_item.name).to eq('Dinner Bundle')
        expect(order_item.price_at_purchase).to eq(24.99)
        expect(order_item.total_price).to eq(24.99)
      end

      it 'maintains historical price even if bundle price changes' do
        order_item = create(:order_item,
          order: order,
          item_type: 'bundle',
          item_id: bundle.id,
          name: bundle.name,
          price_at_purchase: 24.99,
          quantity: 1
        )

        # Bundle price changes after order
        bundle.update!(bundle_price: 19.99)

        expect(order_item.price_at_purchase).to eq(24.99) # Historical price preserved
        expect(bundle.bundle_price).to eq(19.99) # Current price updated
      end
    end

    context 'mixed order with products and bundles' do
      let!(:product) { create(:product, merchant: merchant, discounted_price: 8.50) }
      let!(:bundle) { create(:bundle, merchant: merchant, bundle_price: 20.00) }
      let!(:product_item) { create(:order_item, order: order, item_type: 'product', item_id: product.id, price_at_purchase: 8.50, quantity: 2) }
      let!(:bundle_item) { create(:order_item, order: order, item_type: 'bundle', item_id: bundle.id, price_at_purchase: 20.00, quantity: 1) }

      it 'calculates correct totals for mixed order' do
        expect(product_item.total_price).to eq(17.00) # 8.50 * 2
        expect(bundle_item.total_price).to eq(20.00)  # 20.00 * 1

        # Total order value should be 37.00
        total_order_value = order.order_items.sum(&:total_price)
        expect(total_order_value).to eq(37.00)
      end
    end
  end

  describe 'edge cases' do
    let!(:merchant) { create(:merchant) }
    let!(:customer) { create(:customer) }
    let!(:order) { create(:order, customer: customer, merchant: merchant) }

    it 'handles item deletion after order creation' do
      product = create(:product, merchant: merchant)
      order_item = create(:order_item, order: order, item_type: 'product', item_id: product.id)

      product.destroy

      # Order item should still exist but item method returns nil
      expect(order_item.reload).to be_persisted
      expect(order_item.item).to be_nil
      expect(order_item.name).to be_present # Historical name preserved
      expect(order_item.price_at_purchase).to be_present # Historical price preserved
    end

    it 'handles very large quantities and prices' do
      order_item = build(:order_item, price_at_purchase: 999.99, quantity: 1000)
      expect(order_item).to be_valid
      expect(order_item.total_price).to eq(999990.00)
    end

    it 'handles very small prices' do
      order_item = build(:order_item, price_at_purchase: 0.01, quantity: 1)
      expect(order_item).to be_valid
      expect(order_item.total_price).to eq(0.01)
    end
  end

  describe 'factory behavior' do
    it 'creates valid order item' do
      expect(build(:order_item)).to be_valid
    end

    it 'creates product items correctly' do
      order_item = create(:order_item, :product_item)
      expect(order_item.item_type).to eq('product')
      expect(order_item.item).to be_a(Product)
    end

    it 'creates bundle items correctly' do
      order_item = create(:order_item, :bundle_item)
      expect(order_item.item_type).to eq('bundle')
      expect(order_item.item).to be_a(Bundle)
    end

    it 'ensures item belongs to same merchant as order' do
      order_item = create(:order_item)
      case order_item.item_type
      when 'product'
        expect(order_item.item.merchant).to eq(order_item.order.merchant)
      when 'bundle'
        expect(order_item.item.merchant).to eq(order_item.order.merchant)
      end
    end

    context 'with traits' do
      it 'creates single quantity items' do
        order_item = build(:order_item, :single_quantity)
        expect(order_item.quantity).to eq(1)
      end

      it 'creates multiple quantity items' do
        order_item = build(:order_item, :multiple_quantity)
        expect(order_item.quantity).to be >= 3
      end

      it 'creates expensive items' do
        order_item = build(:order_item, :expensive_item)
        expect(order_item.price_at_purchase).to be >= 25.00
      end

      it 'creates cheap items' do
        order_item = build(:order_item, :cheap_item)
        expect(order_item.price_at_purchase).to be <= 15.00
      end
    end
  end

  describe 'integration with Order#calculate_total!' do
    let!(:order) { create(:order, total_amount: 0) }

    it 'is included in order total calculation' do
      order_item1 = create(:order_item, order: order, price_at_purchase: 10.00, quantity: 2)
      order_item2 = create(:order_item, order: order, price_at_purchase: 5.50, quantity: 1)

      order.calculate_total!
      expect(order.total_amount).to eq(25.50) # (10.00 * 2) + (5.50 * 1)
    end

    it 'updates order total when order items change' do
      order_item = create(:order_item, order: order, price_at_purchase: 8.00, quantity: 3)
      order.calculate_total!
      expect(order.total_amount).to eq(24.00)

      order_item.update!(quantity: 5)
      order.calculate_total!
      expect(order.total_amount).to eq(40.00)
    end
  end

  describe 'data consistency' do
    let!(:merchant) { create(:merchant) }
    let!(:customer) { create(:customer) }
    let!(:order) { create(:order, customer: customer, merchant: merchant) }
    let!(:product) { create(:product, merchant: merchant, name: 'Original Name', discounted_price: 10.00) }

    it 'maintains order item integrity when referenced item changes' do
      order_item = create(:order_item,
        order: order,
        item_type: 'product',
        item_id: product.id,
        name: 'Original Name',
        price_at_purchase: 10.00,
        quantity: 1
      )

      # Product changes after order
      product.update!(name: 'Updated Name', discounted_price: 15.00)

      # Order item preserves historical data
      expect(order_item.name).to eq('Original Name')
      expect(order_item.price_at_purchase).to eq(10.00)

      # But can still reference the updated product
      expect(order_item.item.name).to eq('Updated Name')
      expect(order_item.item.discounted_price).to eq(15.00)
    end
  end
end
