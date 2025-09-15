require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product) { build(:product) }

  describe 'associations' do
    it { should belong_to(:merchant) }
    it { should have_many(:bundle_items).dependent(:destroy) }
    it { should have_many(:bundles).through(:bundle_items) }

    context 'when product is destroyed' do
      let!(:product) { create(:product) }
      let!(:bundle_item) { create(:bundle_item, product: product) }

      it 'destroys associated bundle_items' do
        expect { product.destroy }.to change { BundleItem.count }.by(-1)
      end
    end
  end

  describe 'validations' do
    subject { product }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:original_price) }
    it { should validate_presence_of(:discounted_price) }
    it { should validate_presence_of(:discount_percentage) }
    it { should validate_presence_of(:available_quantity) }
    it { should validate_presence_of(:expires_at) }

    it { should validate_numericality_of(:original_price).is_greater_than(0) }
    it { should validate_numericality_of(:discounted_price).is_greater_than(0) }
    it { should validate_numericality_of(:discount_percentage).is_greater_than(0) }
    it { should validate_numericality_of(:discount_percentage).is_less_than_or_equal_to(99) }
    it { should validate_numericality_of(:available_quantity).is_greater_than_or_equal_to(0) }

    context 'price validations' do
      it 'accepts valid prices' do
        product = build(:product, original_price: 10.00, discounted_price: 8.00)
        expect(product).to be_valid
      end

      it 'rejects zero or negative original price' do
        [0, -1, -0.01].each do |price|
          product.original_price = price
          expect(product).not_to be_valid
          expect(product.errors[:original_price]).to include('must be greater than 0')
        end
      end

      it 'rejects zero or negative discounted price' do
        [0, -1, -0.01].each do |price|
          product.discounted_price = price
          expect(product).not_to be_valid
          expect(product.errors[:discounted_price]).to include('must be greater than 0')
        end
      end
    end

    context 'discount percentage validation' do
      it 'accepts valid discount percentages' do
        [1, 25, 50, 99].each do |discount|
          product.discount_percentage = discount
          expect(product).to be_valid
        end
      end

      it 'rejects zero discount percentage' do
        product.discount_percentage = 0
        expect(product).not_to be_valid
        expect(product.errors[:discount_percentage]).to include('must be greater than 0')
      end

      it 'rejects discount percentage of 100 or more' do
        [100, 150].each do |discount|
          product.discount_percentage = discount
          expect(product).not_to be_valid
          expect(product.errors[:discount_percentage]).to include('must be less than or equal to 99')
        end
      end

      it 'rejects negative discount percentage' do
        product.discount_percentage = -5
        expect(product).not_to be_valid
        expect(product.errors[:discount_percentage]).to include('must be greater than 0')
      end
    end

    context 'quantity validation' do
      it 'accepts zero quantity' do
        product.available_quantity = 0
        expect(product).to be_valid
      end

      it 'accepts positive quantities' do
        [1, 5, 100].each do |quantity|
          product.available_quantity = quantity
          expect(product).to be_valid
        end
      end

      it 'rejects negative quantities' do
        product.available_quantity = -1
        expect(product).not_to be_valid
        expect(product.errors[:available_quantity]).to include('must be greater than or equal to 0')
      end
    end
  end

  describe 'custom validations' do
    describe 'discounted_price_less_than_original' do
      it 'allows discounted price less than original price' do
        product = build(:product, original_price: 10.00, discounted_price: 8.00)
        expect(product).to be_valid
      end

      it 'rejects discounted price equal to original price' do
        product = build(:product, original_price: 10.00, discounted_price: 10.00)
        expect(product).not_to be_valid
        expect(product.errors[:discounted_price]).to include('must be less than original price')
      end

      it 'rejects discounted price greater than original price' do
        product = build(:product, original_price: 10.00, discounted_price: 12.00)
        expect(product).not_to be_valid
        expect(product.errors[:discounted_price]).to include('must be less than original price')
      end

      it 'skips validation when prices are nil' do
        product = build(:product, original_price: nil, discounted_price: nil)
        product.valid?
        expect(product.errors[:discounted_price]).not_to include('must be less than original price')
      end
    end

    describe 'expires_at_in_future' do
      it 'allows future expiration dates' do
        product = build(:product, expires_at: 1.hour.from_now)
        expect(product).to be_valid
      end

      it 'rejects past expiration dates' do
        product = build(:product, expires_at: 1.hour.ago)
        expect(product).not_to be_valid
        expect(product.errors[:expires_at]).to include('must be in the future')
      end

      it 'rejects current time as expiration' do
        travel_to(Time.current) do
          product = build(:product, expires_at: Time.current)
          expect(product).not_to be_valid
          expect(product.errors[:expires_at]).to include('must be in the future')
        end
      end

      it 'skips validation when expires_at is nil' do
        product = build(:product, expires_at: nil)
        product.valid?
        expect(product.errors[:expires_at]).not_to include('must be in the future')
      end
    end
  end

  describe 'scopes' do
    let!(:merchant) { create(:merchant) }
    let!(:available_product) { create(:product, merchant: merchant, available_quantity: 5, expires_at: 2.hours.from_now) }
    let!(:out_of_stock_product) { create(:product, merchant: merchant, available_quantity: 0, expires_at: 2.hours.from_now) }
    let!(:expired_product) { create(:product, merchant: merchant, available_quantity: 3, expires_at: 1.hour.ago) }
    let!(:bakery_product) { create(:product, :bakery, merchant: merchant, available_quantity: 2, expires_at: 3.hours.from_now) }
    let!(:produce_product) { create(:product, :produce, merchant: merchant, available_quantity: 4, expires_at: 4.hours.from_now) }
    let!(:expiring_soon_product) { create(:product, :expiring_soon, merchant: merchant, available_quantity: 1) }

    describe '.available' do
      it 'returns only products with quantity > 0 and not expired' do
        available_products = Product.available
        expect(available_products).to include(available_product, bakery_product, produce_product, expiring_soon_product)
        expect(available_products).not_to include(out_of_stock_product, expired_product)
      end
    end

    describe '.by_category' do
      it 'returns products filtered by category' do
        bakery_products = Product.by_category('bakery')
        expect(bakery_products).to include(bakery_product)
        expect(bakery_products).not_to include(available_product, produce_product)
      end

      it 'returns empty collection for non-existent category' do
        non_existent = Product.by_category('non_existent')
        expect(non_existent).to be_empty
      end
    end

    describe '.expiring_soon' do
      it 'returns products expiring within default 2 hours' do
        expiring_products = Product.expiring_soon
        expect(expiring_products).to include(expiring_soon_product)
        expect(expiring_products).not_to include(available_product, bakery_product, produce_product)
      end

      it 'accepts custom hours parameter' do
        expiring_products = Product.expiring_soon(5)
        expect(expiring_products).to include(expiring_soon_product, available_product, bakery_product)
        expect(expiring_products).not_to include(produce_product) # expires in 4 hours
      end
    end
  end

  describe 'instance methods' do
    describe '#discount_amount' do
      it 'calculates correct discount amount' do
        product = build(:product, original_price: 20.00, discounted_price: 15.00)
        expect(product.discount_amount).to eq(5.00)
      end

      it 'handles decimal calculations correctly' do
        product = build(:product, original_price: 12.99, discounted_price: 9.99)
        expect(product.discount_amount).to eq(3.00)
      end

      it 'returns zero when prices are equal' do
        product = build(:product, original_price: 10.00, discounted_price: 10.00)
        expect(product.discount_amount).to eq(0.00)
      end
    end

    describe '#expired?' do
      it 'returns true for expired products' do
        product = build(:product, expires_at: 1.hour.ago)
        expect(product.expired?).to be true
      end

      it 'returns false for future expiration' do
        product = build(:product, expires_at: 1.hour.from_now)
        expect(product.expired?).to be false
      end

      it 'returns true for products expiring exactly now' do
        travel_to(Time.current) do
          product = build(:product, expires_at: Time.current)
          expect(product.expired?).to be true
        end
      end
    end

    describe '#available?' do
      it 'returns true for products with quantity and not expired' do
        product = build(:product, available_quantity: 5, expires_at: 1.hour.from_now)
        expect(product.available?).to be true
      end

      it 'returns false for products with zero quantity' do
        product = build(:product, available_quantity: 0, expires_at: 1.hour.from_now)
        expect(product.available?).to be false
      end

      it 'returns false for expired products even with quantity' do
        product = build(:product, available_quantity: 5, expires_at: 1.hour.ago)
        expect(product.available?).to be false
      end

      it 'returns false for products with zero quantity and expired' do
        product = build(:product, available_quantity: 0, expires_at: 1.hour.ago)
        expect(product.available?).to be false
      end
    end
  end

  describe 'edge cases' do
    it 'handles very small prices correctly' do
      product = build(:product, original_price: 0.01, discounted_price: 0.005)
      expect(product).not_to be_valid
      expect(product.errors[:discounted_price]).to include('must be greater than 0')
    end

    it 'handles very large prices correctly' do
      product = build(:product, original_price: 999999.99, discounted_price: 500000.00)
      expect(product).to be_valid
    end

    it 'handles high quantities correctly' do
      product = build(:product, available_quantity: 10000)
      expect(product).to be_valid
    end

    it 'handles far future expiration dates' do
      product = build(:product, expires_at: 1.year.from_now)
      expect(product).to be_valid
    end
  end

  describe 'factory traits' do
    it 'creates expired products' do
      product = build(:product, :expired)
      expect(product.expired?).to be true
    end

    it 'creates expiring soon products' do
      product = build(:product, :expiring_soon)
      expect(product.expires_at).to be_between(30.minutes.from_now, 90.minutes.from_now)
    end

    it 'creates out of stock products' do
      product = build(:product, :out_of_stock)
      expect(product.available_quantity).to eq(0)
    end

    it 'creates bakery products with appropriate attributes' do
      product = build(:product, :bakery)
      expect(product.category).to eq('bakery')
      expect(product.allergens).to include('gluten', 'eggs', 'dairy')
    end

    it 'creates produce products with appropriate attributes' do
      product = build(:product, :produce)
      expect(product.category).to eq('produce')
      expect(product.allergens).to eq([])
    end
  end

  describe 'factory' do
    it 'creates valid product' do
      expect(build(:product)).to be_valid
    end

    it 'ensures discounted price is less than original price' do
      product = create(:product)
      expect(product.discounted_price).to be < product.original_price
    end

    it 'ensures expires_at is in the future' do
      product = create(:product)
      expect(product.expires_at).to be > Time.current
    end
  end
end
