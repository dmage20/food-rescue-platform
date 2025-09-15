require 'rails_helper'

RSpec.describe Merchant, type: :model do
  let(:merchant) { build(:merchant) }

  describe 'associations' do
    it { should have_many(:products).dependent(:destroy) }
    it { should have_many(:bundles).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }

    context 'when merchant is destroyed' do
      let!(:merchant) { create(:merchant) }
      let!(:product) { create(:product, merchant: merchant) }
      let!(:bundle) { create(:bundle, merchant: merchant) }
      let!(:order) { create(:order, merchant: merchant) }

      it 'destroys associated products' do
        expect { merchant.destroy }.to change { Product.count }.by(-1)
      end

      it 'destroys associated bundles' do
        expect { merchant.destroy }.to change { Bundle.count }.by(-1)
      end

      it 'destroys associated orders' do
        expect { merchant.destroy }.to change { Order.count }.by(-1)
      end
    end
  end

  describe 'validations' do
    subject { merchant }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_numericality_of(:latitude) }
    it { should validate_numericality_of(:longitude) }
    it { should allow_value('merchant@example.com').for(:email) }
    it { should_not allow_value('invalid-email').for(:email) }
    it { should_not allow_value('').for(:email) }
    it { should_not allow_value(nil).for(:email) }

    context 'when email is already taken' do
      let!(:existing_merchant) { create(:merchant, email: 'taken@example.com') }

      it 'validates uniqueness of email' do
        duplicate_merchant = build(:merchant, email: 'taken@example.com')
        expect(duplicate_merchant).not_to be_valid
        expect(duplicate_merchant.errors[:email]).to include('has already been taken')
      end
    end

    context 'latitude and longitude validation' do
      it 'accepts valid latitude values' do
        [-90, -45.5, 0, 45.5, 90].each do |lat|
          merchant.latitude = lat
          expect(merchant).to be_valid
        end
      end

      it 'accepts valid longitude values' do
        [-180, -122.4, 0, 122.4, 180].each do |lng|
          merchant.longitude = lng
          expect(merchant).to be_valid
        end
      end

      it 'rejects non-numeric latitude' do
        merchant.latitude = 'not a number'
        expect(merchant).not_to be_valid
      end

      it 'rejects non-numeric longitude' do
        merchant.longitude = 'not a number'
        expect(merchant).not_to be_valid
      end
    end
  end

  describe 'Devise authentication' do
    it 'includes database_authenticatable module' do
      expect(Merchant.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(Merchant.devise_modules).to include(:registerable)
    end

    it 'includes jwt_authenticatable module' do
      expect(Merchant.devise_modules).to include(:jwt_authenticatable)
    end

    it 'encrypts password on save' do
      merchant = build(:merchant, password: 'password123')
      expect { merchant.save! }.to change { merchant.encrypted_password }.from(nil)
    end

    it 'authenticates with valid password' do
      merchant = create(:merchant, password: 'password123')
      expect(merchant.valid_password?('password123')).to be true
    end

    it 'does not authenticate with invalid password' do
      merchant = create(:merchant, password: 'password123')
      expect(merchant.valid_password?('wrongpassword')).to be false
    end
  end

  describe 'scopes' do
    describe '.nearby' do
      let!(:sf_merchant) { create(:merchant, :san_francisco) }
      let!(:la_merchant) { create(:merchant, :los_angeles) }
      let!(:distant_merchant) { create(:merchant, latitude: 40.7128, longitude: -74.0060) } # New York

      context 'with default radius (5km)' do
        it 'finds merchants within 5km of SF' do
          nearby = Merchant.nearby(37.7749, -122.4194)
          expect(nearby).to include(sf_merchant)
          expect(nearby).not_to include(la_merchant)
          expect(nearby).not_to include(distant_merchant)
        end
      end

      context 'with custom radius' do
        it 'finds merchants within specified radius' do
          # LA is about 560km from SF, so use 600km radius
          nearby = Merchant.nearby(37.7749, -122.4194, 600)
          expect(nearby).to include(sf_merchant)
          expect(nearby).to include(la_merchant)
          expect(nearby).not_to include(distant_merchant)
        end
      end

      context 'with very large radius' do
        it 'finds all merchants within large radius' do
          nearby = Merchant.nearby(37.7749, -122.4194, 5000) # 5000km
          expect(nearby).to include(sf_merchant)
          expect(nearby).to include(la_merchant)
          expect(nearby).to include(distant_merchant)
        end
      end

      context 'with zero radius' do
        it 'finds only exact matches' do
          nearby = Merchant.nearby(37.7749, -122.4194, 0)
          expect(nearby).to include(sf_merchant)
          expect(nearby).not_to include(la_merchant)
        end
      end
    end
  end

  describe '#available_products' do
    let!(:merchant) { create(:merchant) }
    let!(:available_product) { create(:product, merchant: merchant, available_quantity: 5, expires_at: 2.hours.from_now) }
    let!(:out_of_stock_product) { create(:product, merchant: merchant, available_quantity: 0, expires_at: 2.hours.from_now) }
    let!(:expired_product) { create(:product, merchant: merchant, available_quantity: 3, expires_at: 1.hour.ago) }
    let!(:other_merchant_product) { create(:product, available_quantity: 5, expires_at: 2.hours.from_now) }

    it 'returns only products with quantity > 0 and not expired' do
      available_products = merchant.available_products
      expect(available_products).to include(available_product)
      expect(available_products).not_to include(out_of_stock_product)
      expect(available_products).not_to include(expired_product)
      expect(available_products).not_to include(other_merchant_product)
    end

    it 'returns empty collection when no available products' do
      merchant_without_products = create(:merchant)
      expect(merchant_without_products.available_products).to be_empty
    end

    it 'excludes products that expire exactly now' do
      travel_to(Time.current) do
        expiring_now = create(:product, merchant: merchant, available_quantity: 5, expires_at: Time.current)
        expect(merchant.available_products).not_to include(expiring_now)
      end
    end
  end

  describe '#available_bundles' do
    let!(:merchant) { create(:merchant) }
    let!(:available_bundle) { create(:bundle, merchant: merchant, available_quantity: 3, expires_at: 2.hours.from_now) }
    let!(:out_of_stock_bundle) { create(:bundle, merchant: merchant, available_quantity: 0, expires_at: 2.hours.from_now) }
    let!(:expired_bundle) { create(:bundle, merchant: merchant, available_quantity: 2, expires_at: 1.hour.ago) }
    let!(:other_merchant_bundle) { create(:bundle, available_quantity: 3, expires_at: 2.hours.from_now) }

    it 'returns only bundles with quantity > 0 and not expired' do
      available_bundles = merchant.available_bundles
      expect(available_bundles).to include(available_bundle)
      expect(available_bundles).not_to include(out_of_stock_bundle)
      expect(available_bundles).not_to include(expired_bundle)
      expect(available_bundles).not_to include(other_merchant_bundle)
    end

    it 'returns empty collection when no available bundles' do
      merchant_without_bundles = create(:merchant)
      expect(merchant_without_bundles.available_bundles).to be_empty
    end

    it 'excludes bundles that expire exactly now' do
      travel_to(Time.current) do
        expiring_now = create(:bundle, merchant: merchant, available_quantity: 3, expires_at: Time.current)
        expect(merchant.available_bundles).not_to include(expiring_now)
      end
    end
  end

  describe 'factory' do
    it 'creates valid merchant' do
      expect(build(:merchant)).to be_valid
    end

    it 'creates merchant with traits' do
      merchant = build(:merchant, :san_francisco)
      expect(merchant.latitude).to eq(37.7749)
      expect(merchant.longitude).to eq(-122.4194)
      expect(merchant.address).to eq('San Francisco, CA')
    end
  end
end
