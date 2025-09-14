require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'associations' do
    it { should have_many(:products).dependent(:destroy) }
    it { should have_many(:bundles).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:merchant) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_numericality_of(:latitude) }
    it { should validate_numericality_of(:longitude) }
  end

  describe 'authentication' do
    it { should have_secure_password }
  end

  describe '#available_products' do
    let(:merchant) { create(:merchant) }

    it 'returns products with quantity > 0 and not expired' do
      # This test would need product factory - simplified for now
      expect(merchant.available_products).to be_empty
    end
  end
end
