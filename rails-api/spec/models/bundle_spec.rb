require 'rails_helper'

RSpec.describe Bundle, type: :model do
  let(:bundle) { build(:bundle) }

  describe 'associations' do
    it { should belong_to(:merchant) }
    it { should have_many(:bundle_items).dependent(:destroy) }
    it { should have_many(:products).through(:bundle_items) }

    context 'when bundle is destroyed' do
      let!(:bundle) { create(:bundle) }
      let!(:bundle_item) { create(:bundle_item, bundle: bundle) }

      it 'destroys associated bundle_items' do
        expect { bundle.destroy }.to change { BundleItem.count }.by(-1)
      end
    end
  end

  describe 'validations' do
    subject { bundle }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:total_original_price) }
    it { should validate_presence_of(:bundle_price) }
    it { should validate_presence_of(:discount_percentage) }
    it { should validate_presence_of(:available_quantity) }
    it { should validate_presence_of(:expires_at) }

    it { should validate_numericality_of(:total_original_price).is_greater_than(0) }
    it { should validate_numericality_of(:bundle_price).is_greater_than(0) }
    it { should validate_numericality_of(:discount_percentage).is_greater_than(0) }
    it { should validate_numericality_of(:discount_percentage).is_less_than_or_equal_to(99) }
    it { should validate_numericality_of(:available_quantity).is_greater_than_or_equal_to(0) }

    context 'price validations' do
      it 'accepts valid prices' do
        bundle = build(:bundle, total_original_price: 20.00, bundle_price: 15.00)
        expect(bundle).to be_valid
      end

      it 'rejects zero or negative total original price' do
        [0, -1, -0.01].each do |price|
          bundle.total_original_price = price
          expect(bundle).not_to be_valid
          expect(bundle.errors[:total_original_price]).to include('must be greater than 0')
        end
      end

      it 'rejects zero or negative bundle price' do
        [0, -1, -0.01].each do |price|
          bundle.bundle_price = price
          expect(bundle).not_to be_valid
          expect(bundle.errors[:bundle_price]).to include('must be greater than 0')
        end
      end
    end

    context 'discount percentage validation' do
      it 'accepts valid discount percentages' do
        [1, 25, 50, 99].each do |discount|
          bundle.discount_percentage = discount
          expect(bundle).to be_valid
        end
      end

      it 'rejects zero discount percentage' do
        bundle.discount_percentage = 0
        expect(bundle).not_to be_valid
        expect(bundle.errors[:discount_percentage]).to include('must be greater than 0')
      end

      it 'rejects discount percentage of 100 or more' do
        [100, 150].each do |discount|
          bundle.discount_percentage = discount
          expect(bundle).not_to be_valid
          expect(bundle.errors[:discount_percentage]).to include('must be less than or equal to 99')
        end
      end

      it 'rejects negative discount percentage' do
        bundle.discount_percentage = -5
        expect(bundle).not_to be_valid
        expect(bundle.errors[:discount_percentage]).to include('must be greater than 0')
      end
    end

    context 'quantity validation' do
      it 'accepts zero quantity' do
        bundle.available_quantity = 0
        expect(bundle).to be_valid
      end

      it 'accepts positive quantities' do
        [1, 5, 100].each do |quantity|
          bundle.available_quantity = quantity
          expect(bundle).to be_valid
        end
      end

      it 'rejects negative quantities' do
        bundle.available_quantity = -1
        expect(bundle).not_to be_valid
        expect(bundle.errors[:available_quantity]).to include('must be greater than or equal to 0')
      end
    end
  end

  describe 'custom validations' do
    describe 'bundle_price_less_than_total' do
      it 'allows bundle price less than total original price' do
        bundle = build(:bundle, total_original_price: 20.00, bundle_price: 15.00)
        expect(bundle).to be_valid
      end

      it 'rejects bundle price equal to total original price' do
        bundle = build(:bundle, total_original_price: 20.00, bundle_price: 20.00)
        expect(bundle).not_to be_valid
        expect(bundle.errors[:bundle_price]).to include('must be less than total original price')
      end

      it 'rejects bundle price greater than total original price' do
        bundle = build(:bundle, total_original_price: 20.00, bundle_price: 25.00)
        expect(bundle).not_to be_valid
        expect(bundle.errors[:bundle_price]).to include('must be less than total original price')
      end

      it 'skips validation when prices are nil' do
        bundle = build(:bundle, total_original_price: nil, bundle_price: nil)
        bundle.valid?
        expect(bundle.errors[:bundle_price]).not_to include('must be less than total original price')
      end
    end

    describe 'expires_at_in_future' do
      it 'allows future expiration dates' do
        bundle = build(:bundle, expires_at: 1.hour.from_now)
        expect(bundle).to be_valid
      end

      it 'rejects past expiration dates' do
        bundle = build(:bundle, expires_at: 1.hour.ago)
        expect(bundle).not_to be_valid
        expect(bundle.errors[:expires_at]).to include('must be in the future')
      end

      it 'rejects current time as expiration' do
        travel_to(Time.current) do
          bundle = build(:bundle, expires_at: Time.current)
          expect(bundle).not_to be_valid
          expect(bundle.errors[:expires_at]).to include('must be in the future')
        end
      end

      it 'skips validation when expires_at is nil' do
        bundle = build(:bundle, expires_at: nil)
        bundle.valid?
        expect(bundle.errors[:expires_at]).not_to include('must be in the future')
      end
    end
  end

  describe 'scopes' do
    let!(:merchant) { create(:merchant) }
    let!(:available_bundle) { create(:bundle, merchant: merchant, available_quantity: 3, expires_at: 2.hours.from_now) }
    let!(:out_of_stock_bundle) { create(:bundle, merchant: merchant, available_quantity: 0, expires_at: 2.hours.from_now) }
    let!(:expired_bundle) { create(:bundle, merchant: merchant, available_quantity: 2, expires_at: 1.hour.ago) }
    let!(:expiring_soon_bundle) { create(:bundle, :expiring_soon, merchant: merchant, available_quantity: 1) }

    describe '.available' do
      it 'returns only bundles with quantity > 0 and not expired' do
        available_bundles = Bundle.available
        expect(available_bundles).to include(available_bundle, expiring_soon_bundle)
        expect(available_bundles).not_to include(out_of_stock_bundle, expired_bundle)
      end
    end

    describe '.expiring_soon' do
      it 'returns bundles expiring within default 2 hours' do
        expiring_bundles = Bundle.expiring_soon
        expect(expiring_bundles).to include(expiring_soon_bundle)
        expect(expiring_bundles).not_to include(available_bundle)
      end

      it 'accepts custom hours parameter' do
        expiring_bundles = Bundle.expiring_soon(3)
        expect(expiring_bundles).to include(expiring_soon_bundle, available_bundle)
        expect(expiring_bundles).not_to include(expired_bundle, out_of_stock_bundle)
      end
    end
  end

  describe 'instance methods' do
    describe '#discount_amount' do
      it 'calculates correct discount amount' do
        bundle = build(:bundle, total_original_price: 30.00, bundle_price: 20.00)
        expect(bundle.discount_amount).to eq(10.00)
      end

      it 'handles decimal calculations correctly' do
        bundle = build(:bundle, total_original_price: 25.99, bundle_price: 19.99)
        expect(bundle.discount_amount).to eq(6.00)
      end

      it 'returns zero when prices are equal' do
        bundle = build(:bundle, total_original_price: 20.00, bundle_price: 20.00)
        expect(bundle.discount_amount).to eq(0.00)
      end
    end

    describe '#expired?' do
      it 'returns true for expired bundles' do
        bundle = build(:bundle, expires_at: 1.hour.ago)
        expect(bundle.expired?).to be true
      end

      it 'returns false for future expiration' do
        bundle = build(:bundle, expires_at: 1.hour.from_now)
        expect(bundle.expired?).to be false
      end

      it 'returns true for bundles expiring exactly now' do
        travel_to(Time.current) do
          bundle = build(:bundle, expires_at: Time.current)
          expect(bundle.expired?).to be true
        end
      end
    end

    describe '#available?' do
      it 'returns true for bundles with quantity and not expired' do
        bundle = build(:bundle, available_quantity: 3, expires_at: 1.hour.from_now)
        expect(bundle.available?).to be true
      end

      it 'returns false for bundles with zero quantity' do
        bundle = build(:bundle, available_quantity: 0, expires_at: 1.hour.from_now)
        expect(bundle.available?).to be false
      end

      it 'returns false for expired bundles even with quantity' do
        bundle = build(:bundle, available_quantity: 3, expires_at: 1.hour.ago)
        expect(bundle.available?).to be false
      end

      it 'returns false for bundles with zero quantity and expired' do
        bundle = build(:bundle, available_quantity: 0, expires_at: 1.hour.ago)
        expect(bundle.available?).to be false
      end
    end
  end

  describe 'bundle with products integration' do
    let!(:merchant) { create(:merchant) }
    let!(:bundle) { create(:bundle, :with_products, merchant: merchant) }

    it 'has associated products through bundle_items' do
      expect(bundle.products.count).to eq(3)
      expect(bundle.bundle_items.count).to eq(3)
    end

    it 'all products belong to the same merchant as bundle' do
      bundle.products.each do |product|
        expect(product.merchant).to eq(bundle.merchant)
      end
    end

    it 'calculates total original price from products' do
      expected_total = bundle.bundle_items.sum { |bi| bi.product.original_price * bi.quantity }
      expect(bundle.total_original_price).to eq(expected_total)
    end

    it 'calculates bundle price based on discount percentage' do
      expected_bundle_price = (bundle.total_original_price * (1 - bundle.discount_percentage / 100.0)).round(2)
      expect(bundle.bundle_price).to eq(expected_bundle_price)
    end
  end

  describe 'edge cases' do
    it 'handles very small prices correctly' do
      bundle = build(:bundle, total_original_price: 0.01, bundle_price: 0.005)
      expect(bundle).not_to be_valid
      expect(bundle.errors[:bundle_price]).to include('must be greater than 0')
    end

    it 'handles very large prices correctly' do
      bundle = build(:bundle, total_original_price: 999999.99, bundle_price: 500000.00)
      expect(bundle).to be_valid
    end

    it 'handles high quantities correctly' do
      bundle = build(:bundle, available_quantity: 10000)
      expect(bundle).to be_valid
    end

    it 'handles far future expiration dates' do
      bundle = build(:bundle, expires_at: 1.year.from_now)
      expect(bundle).to be_valid
    end
  end

  describe 'factory traits' do
    it 'creates expired bundles' do
      bundle = build(:bundle, :expired)
      expect(bundle.expired?).to be true
    end

    it 'creates expiring soon bundles' do
      bundle = build(:bundle, :expiring_soon)
      expect(bundle.expires_at).to be_between(30.minutes.from_now, 90.minutes.from_now)
    end

    it 'creates out of stock bundles' do
      bundle = build(:bundle, :out_of_stock)
      expect(bundle.available_quantity).to eq(0)
    end

    it 'creates high value bundles' do
      bundle = build(:bundle, :high_value)
      expect(bundle.total_original_price).to be >= 50.00
    end

    it 'creates low value bundles' do
      bundle = build(:bundle, :low_value)
      expect(bundle.total_original_price).to be <= 25.00
    end

    it 'creates bundles with products' do
      bundle = create(:bundle, :with_products)
      expect(bundle.products.count).to eq(3)
      expect(bundle.bundle_items.count).to eq(3)
    end
  end

  describe 'factory' do
    it 'creates valid bundle' do
      expect(build(:bundle)).to be_valid
    end

    it 'ensures bundle price is less than total original price' do
      bundle = create(:bundle)
      expect(bundle.bundle_price).to be < bundle.total_original_price
    end

    it 'ensures expires_at is in the future' do
      bundle = create(:bundle)
      expect(bundle.expires_at).to be > Time.current
    end
  end
end
