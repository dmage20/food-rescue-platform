require 'rails_helper'

RSpec.describe BundleItem, type: :model do
  let(:bundle_item) { build(:bundle_item) }

  describe 'associations' do
    it { should belong_to(:bundle) }
    it { should belong_to(:product) }

    context 'when bundle_item references valid objects' do
      let!(:merchant) { create(:merchant) }
      let!(:bundle) { create(:bundle, merchant: merchant) }
      let!(:product) { create(:product, merchant: merchant) }
      let!(:bundle_item) { create(:bundle_item, bundle: bundle, product: product) }

      it 'belongs to a bundle' do
        expect(bundle_item.bundle).to eq(bundle)
      end

      it 'belongs to a product' do
        expect(bundle_item.product).to eq(product)
      end
    end
  end

  describe 'validations' do
    subject { bundle_item }

    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_uniqueness_of(:bundle_id).scoped_to(:product_id) }

    context 'quantity validation' do
      it 'accepts positive quantities' do
        [1, 5, 100].each do |quantity|
          bundle_item.quantity = quantity
          expect(bundle_item).to be_valid
        end
      end

      it 'rejects zero quantity' do
        bundle_item.quantity = 0
        expect(bundle_item).not_to be_valid
        expect(bundle_item.errors[:quantity]).to include('must be greater than 0')
      end

      it 'rejects negative quantities' do
        bundle_item.quantity = -1
        expect(bundle_item).not_to be_valid
        expect(bundle_item.errors[:quantity]).to include('must be greater than 0')
      end

      it 'rejects non-numeric quantities' do
        bundle_item.quantity = 'not a number'
        expect(bundle_item).not_to be_valid
      end
    end

    context 'uniqueness validation' do
      let!(:merchant) { create(:merchant) }
      let!(:bundle) { create(:bundle, merchant: merchant) }
      let!(:product) { create(:product, merchant: merchant) }

      it 'allows multiple bundle items for different bundles with same product' do
        bundle_item1 = create(:bundle_item, bundle: bundle, product: product)
        another_bundle = create(:bundle, merchant: merchant)
        bundle_item2 = build(:bundle_item, bundle: another_bundle, product: product)

        expect(bundle_item2).to be_valid
      end

      it 'allows multiple bundle items for same bundle with different products' do
        bundle_item1 = create(:bundle_item, bundle: bundle, product: product)
        another_product = create(:product, merchant: merchant)
        bundle_item2 = build(:bundle_item, bundle: bundle, product: another_product)

        expect(bundle_item2).to be_valid
      end

      it 'prevents duplicate bundle_id/product_id combinations' do
        bundle_item1 = create(:bundle_item, bundle: bundle, product: product)
        bundle_item2 = build(:bundle_item, bundle: bundle, product: product)

        expect(bundle_item2).not_to be_valid
        expect(bundle_item2.errors[:bundle_id]).to include('has already been taken')
      end
    end
  end

  describe 'business logic constraints' do
    context 'when product and bundle belong to different merchants' do
      let!(:merchant1) { create(:merchant) }
      let!(:merchant2) { create(:merchant) }
      let!(:bundle) { create(:bundle, merchant: merchant1) }
      let!(:product) { create(:product, merchant: merchant2) }

      it 'can create bundle_item with products from different merchants' do
        # Note: The factory ensures same merchant, but this tests manual creation
        bundle_item = build(:bundle_item, bundle: bundle, product: product)
        expect(bundle_item).to be_valid
      end
    end

    context 'when product is from same merchant as bundle' do
      let!(:merchant) { create(:merchant) }
      let!(:bundle) { create(:bundle, merchant: merchant) }
      let!(:product) { create(:product, merchant: merchant) }

      it 'creates valid bundle_item' do
        bundle_item = build(:bundle_item, bundle: bundle, product: product)
        expect(bundle_item).to be_valid
      end
    end
  end

  describe 'edge cases' do
    it 'handles very large quantities' do
      bundle_item = build(:bundle_item, quantity: 10000)
      expect(bundle_item).to be_valid
    end

    it 'handles decimal quantities (if allowed by business logic)' do
      bundle_item = build(:bundle_item, quantity: 2.5)
      expect(bundle_item).to be_valid # This depends on your business requirements
    end

    context 'when bundle is deleted' do
      let!(:merchant) { create(:merchant) }
      let!(:bundle) { create(:bundle, merchant: merchant) }
      let!(:product) { create(:product, merchant: merchant) }
      let!(:bundle_item) { create(:bundle_item, bundle: bundle, product: product) }

      it 'bundle_item is also deleted due to dependent: :destroy' do
        expect { bundle.destroy }.to change { BundleItem.count }.by(-1)
      end
    end

    context 'when product is deleted' do
      let!(:merchant) { create(:merchant) }
      let!(:bundle) { create(:bundle, merchant: merchant) }
      let!(:product) { create(:product, merchant: merchant) }
      let!(:bundle_item) { create(:bundle_item, bundle: bundle, product: product) }

      it 'bundle_item is also deleted due to dependent: :destroy' do
        expect { product.destroy }.to change { BundleItem.count }.by(-1)
      end
    end
  end

  describe 'factory behavior' do
    it 'creates valid bundle_item' do
      expect(build(:bundle_item)).to be_valid
    end

    it 'ensures product belongs to same merchant as bundle' do
      bundle_item = create(:bundle_item)
      expect(bundle_item.product.merchant).to eq(bundle_item.bundle.merchant)
    end

    context 'with traits' do
      it 'creates single item bundle_item' do
        bundle_item = build(:bundle_item, :single_item)
        expect(bundle_item.quantity).to eq(1)
      end

      it 'creates multiple items bundle_item' do
        bundle_item = build(:bundle_item, :multiple_items)
        expect(bundle_item.quantity).to be >= 3
        expect(bundle_item.quantity).to be <= 8
      end
    end
  end

  describe 'complex scenarios' do
    let!(:merchant) { create(:merchant) }
    let!(:bundle) { create(:bundle, merchant: merchant) }
    let!(:product1) { create(:product, merchant: merchant) }
    let!(:product2) { create(:product, merchant: merchant) }
    let!(:product3) { create(:product, merchant: merchant) }

    it 'allows creating multiple bundle items for same bundle' do
      bundle_item1 = create(:bundle_item, bundle: bundle, product: product1, quantity: 2)
      bundle_item2 = create(:bundle_item, bundle: bundle, product: product2, quantity: 1)
      bundle_item3 = create(:bundle_item, bundle: bundle, product: product3, quantity: 3)

      expect(bundle.bundle_items.count).to eq(3)
      expect(bundle.products.count).to eq(3)
    end

    it 'calculates total items in bundle correctly' do
      create(:bundle_item, bundle: bundle, product: product1, quantity: 2)
      create(:bundle_item, bundle: bundle, product: product2, quantity: 1)
      create(:bundle_item, bundle: bundle, product: product3, quantity: 3)

      total_items = bundle.bundle_items.sum(:quantity)
      expect(total_items).to eq(6)
    end

    it 'allows same product in different bundles' do
      bundle2 = create(:bundle, merchant: merchant)
      bundle_item1 = create(:bundle_item, bundle: bundle, product: product1, quantity: 2)
      bundle_item2 = create(:bundle_item, bundle: bundle2, product: product1, quantity: 1)

      expect(bundle_item1).to be_valid
      expect(bundle_item2).to be_valid
      expect(product1.bundle_items.count).to eq(2)
      expect(product1.bundles.count).to eq(2)
    end
  end

  describe 'database constraints' do
    let!(:merchant) { create(:merchant) }
    let!(:bundle) { create(:bundle, merchant: merchant) }
    let!(:product) { create(:product, merchant: merchant) }

    it 'prevents creating bundle_item with non-existent bundle_id' do
      expect {
        create(:bundle_item, bundle_id: 999999, product: product)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'prevents creating bundle_item with non-existent product_id' do
      expect {
        create(:bundle_item, bundle: bundle, product_id: 999999)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
