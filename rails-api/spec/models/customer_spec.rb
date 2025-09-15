require 'rails_helper'

RSpec.describe Customer, type: :model do
  let(:customer) { build(:customer) }

  describe 'associations' do
    it { should have_many(:orders).dependent(:destroy) }

    context 'when customer is destroyed' do
      let!(:customer) { create(:customer) }
      let!(:order) { create(:order, customer: customer) }

      it 'destroys associated orders' do
        expect { customer.destroy }.to change { Order.count }.by(-1)
      end
    end
  end

  describe 'validations' do
    subject { customer }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:preferred_radius) }
    it { should validate_numericality_of(:preferred_radius).is_greater_than(0) }
    it { should validate_numericality_of(:preferred_radius).is_less_than_or_equal_to(50) }
    it { should allow_value('customer@example.com').for(:email) }
    it { should_not allow_value('invalid-email').for(:email) }
    it { should_not allow_value('').for(:email) }
    it { should_not allow_value(nil).for(:email) }

    context 'when email is already taken' do
      let!(:existing_customer) { create(:customer, email: 'taken@example.com') }

      it 'validates uniqueness of email' do
        duplicate_customer = build(:customer, email: 'taken@example.com')
        expect(duplicate_customer).not_to be_valid
        expect(duplicate_customer.errors[:email]).to include('has already been taken')
      end
    end

    context 'preferred_radius validation' do
      it 'accepts valid radius values' do
        [1, 5, 25, 50].each do |radius|
          customer.preferred_radius = radius
          expect(customer).to be_valid
        end
      end

      it 'rejects radius of 0' do
        customer.preferred_radius = 0
        expect(customer).not_to be_valid
        expect(customer.errors[:preferred_radius]).to include('must be greater than 0')
      end

      it 'rejects negative radius' do
        customer.preferred_radius = -5
        expect(customer).not_to be_valid
        expect(customer.errors[:preferred_radius]).to include('must be greater than 0')
      end

      it 'rejects radius greater than 50' do
        customer.preferred_radius = 51
        expect(customer).not_to be_valid
        expect(customer.errors[:preferred_radius]).to include('must be less than or equal to 50')
      end

      it 'rejects non-numeric radius' do
        customer.preferred_radius = 'not a number'
        expect(customer).not_to be_valid
      end
    end
  end

  describe 'Devise authentication' do
    it 'includes database_authenticatable module' do
      expect(Customer.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(Customer.devise_modules).to include(:registerable)
    end

    it 'includes jwt_authenticatable module' do
      expect(Customer.devise_modules).to include(:jwt_authenticatable)
    end

    it 'encrypts password on save' do
      customer = build(:customer, password: 'password123')
      expect { customer.save! }.to change { customer.encrypted_password }.from(nil)
    end

    it 'authenticates with valid password' do
      customer = create(:customer, password: 'password123')
      expect(customer.valid_password?('password123')).to be true
    end

    it 'does not authenticate with invalid password' do
      customer = create(:customer, password: 'password123')
      expect(customer.valid_password?('wrongpassword')).to be false
    end
  end

  describe 'dietary preferences methods' do
    describe '#allergies' do
      it 'returns allergies array when dietary_preferences has allergies' do
        customer = build(:customer, dietary_preferences: { 'allergies' => ['nuts', 'dairy'] })
        expect(customer.allergies).to eq(['nuts', 'dairy'])
      end

      it 'returns empty array when no allergies' do
        customer = build(:customer, dietary_preferences: { 'preferences' => ['vegetarian'] })
        expect(customer.allergies).to eq([])
      end

      it 'returns empty array when dietary_preferences is nil' do
        customer = build(:customer, dietary_preferences: nil)
        expect(customer.allergies).to eq([])
      end

      it 'returns empty array when dietary_preferences is empty hash' do
        customer = build(:customer, dietary_preferences: {})
        expect(customer.allergies).to eq([])
      end
    end

    describe '#preferences' do
      it 'returns preferences array when dietary_preferences has preferences' do
        customer = build(:customer, dietary_preferences: { 'preferences' => ['vegetarian', 'organic'] })
        expect(customer.preferences).to eq(['vegetarian', 'organic'])
      end

      it 'returns empty array when no preferences' do
        customer = build(:customer, dietary_preferences: { 'allergies' => ['nuts'] })
        expect(customer.preferences).to eq([])
      end

      it 'returns empty array when dietary_preferences is nil' do
        customer = build(:customer, dietary_preferences: nil)
        expect(customer.preferences).to eq([])
      end

      it 'returns empty array when dietary_preferences is empty hash' do
        customer = build(:customer, dietary_preferences: {})
        expect(customer.preferences).to eq([])
      end
    end

    describe '#avoid' do
      it 'returns avoid array when dietary_preferences has avoid' do
        customer = build(:customer, dietary_preferences: { 'avoid' => ['spicy', 'seafood'] })
        expect(customer.avoid).to eq(['spicy', 'seafood'])
      end

      it 'returns empty array when no avoid items' do
        customer = build(:customer, dietary_preferences: { 'allergies' => ['nuts'] })
        expect(customer.avoid).to eq([])
      end

      it 'returns empty array when dietary_preferences is nil' do
        customer = build(:customer, dietary_preferences: nil)
        expect(customer.avoid).to eq([])
      end

      it 'returns empty array when dietary_preferences is empty hash' do
        customer = build(:customer, dietary_preferences: {})
        expect(customer.avoid).to eq([])
      end
    end
  end

  describe 'complex dietary preferences scenarios' do
    it 'handles customer with all dietary restrictions' do
      customer = create(:customer, dietary_preferences: {
        'allergies' => ['nuts', 'dairy'],
        'preferences' => ['vegetarian', 'organic'],
        'avoid' => ['spicy', 'processed']
      })

      expect(customer.allergies).to eq(['nuts', 'dairy'])
      expect(customer.preferences).to eq(['vegetarian', 'organic'])
      expect(customer.avoid).to eq(['spicy', 'processed'])
    end

    it 'handles customer with mixed case keys' do
      customer = build(:customer, dietary_preferences: {
        'Allergies' => ['nuts'],
        'preferences' => ['vegan']
      })

      expect(customer.allergies).to eq([])
      expect(customer.preferences).to eq(['vegan'])
    end

    it 'handles customer with empty arrays' do
      customer = build(:customer, dietary_preferences: {
        'allergies' => [],
        'preferences' => [],
        'avoid' => []
      })

      expect(customer.allergies).to eq([])
      expect(customer.preferences).to eq([])
      expect(customer.avoid).to eq([])
    end
  end

  describe 'factory traits' do
    it 'creates customer with no dietary restrictions' do
      customer = build(:customer, :with_no_dietary_restrictions)
      expect(customer.dietary_preferences).to eq({})
    end

    it 'creates vegetarian customer' do
      customer = build(:customer, :vegetarian)
      expect(customer.preferences).to include('vegetarian')
      expect(customer.avoid).to include('meat')
    end

    it 'creates customer with allergies' do
      customer = build(:customer, :with_allergies)
      expect(customer.allergies).to include('nuts', 'dairy', 'eggs')
    end

    it 'creates customer in San Francisco area' do
      customer = build(:customer, :nearby_san_francisco)
      expect(customer.latitude).to eq(37.7749)
      expect(customer.longitude).to eq(-122.4194)
    end
  end

  describe 'factory' do
    it 'creates valid customer' do
      expect(build(:customer)).to be_valid
    end

    it 'generates unique emails' do
      customer1 = create(:customer)
      customer2 = create(:customer)
      expect(customer1.email).not_to eq(customer2.email)
    end
  end
end
