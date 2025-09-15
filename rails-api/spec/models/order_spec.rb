require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { build(:order) }

  describe 'associations' do
    it { should belong_to(:customer) }
    it { should belong_to(:merchant) }
    it { should have_many(:order_items).dependent(:destroy) }

    context 'when order is destroyed' do
      let!(:order) { create(:order) }
      let!(:order_item) { create(:order_item, order: order) }

      it 'destroys associated order_items' do
        expect { order.destroy }.to change { OrderItem.count }.by(-1)
      end
    end
  end

  describe 'validations' do
    subject { order }

    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending confirmed preparing ready completed cancelled]) }
    it { should validate_presence_of(:confirmation_code) }
    it { should validate_uniqueness_of(:confirmation_code) }
    it { should validate_presence_of(:total_amount) }
    it { should validate_numericality_of(:total_amount).is_greater_than(0) }
    it { should validate_presence_of(:pickup_window_start) }
    it { should validate_presence_of(:pickup_window_end) }

    context 'status validation' do
      it 'accepts valid status values' do
        %w[pending confirmed preparing ready completed cancelled].each do |status|
          order.status = status
          expect(order).to be_valid
        end
      end

      it 'rejects invalid status values' do
        ['invalid_status', '', nil].each do |status|
          order.status = status
          expect(order).not_to be_valid
        end
      end
    end

    context 'confirmation_code validation' do
      let!(:existing_order) { create(:order, confirmation_code: 'AB1234') }

      it 'validates uniqueness of confirmation_code' do
        duplicate_order = build(:order, confirmation_code: 'AB1234')
        expect(duplicate_order).not_to be_valid
        expect(duplicate_order.errors[:confirmation_code]).to include('has already been taken')
      end
    end

    context 'total_amount validation' do
      it 'accepts positive amounts' do
        [0.01, 10.00, 999.99].each do |amount|
          order.total_amount = amount
          expect(order).to be_valid
        end
      end

      it 'rejects zero or negative amounts' do
        [0, -0.01, -10.00].each do |amount|
          order.total_amount = amount
          expect(order).not_to be_valid
          expect(order.errors[:total_amount]).to include('must be greater than 0')
        end
      end
    end
  end

  describe 'custom validations' do
    describe 'pickup_window_end_after_start' do
      it 'allows pickup_window_end after pickup_window_start' do
        order = build(:order,
          pickup_window_start: 2.hours.from_now,
          pickup_window_end: 3.hours.from_now
        )
        expect(order).to be_valid
      end

      it 'rejects pickup_window_end before pickup_window_start' do
        order = build(:order,
          pickup_window_start: 3.hours.from_now,
          pickup_window_end: 2.hours.from_now
        )
        expect(order).not_to be_valid
        expect(order.errors[:pickup_window_end]).to include('must be after pickup window start')
      end

      it 'rejects pickup_window_end equal to pickup_window_start' do
        time = 2.hours.from_now
        order = build(:order,
          pickup_window_start: time,
          pickup_window_end: time
        )
        expect(order).not_to be_valid
        expect(order.errors[:pickup_window_end]).to include('must be after pickup window start')
      end

      it 'skips validation when times are nil' do
        order = build(:order, pickup_window_start: nil, pickup_window_end: nil)
        order.valid?
        expect(order.errors[:pickup_window_end]).not_to include('must be after pickup window start')
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation :generate_confirmation_code' do
      it 'generates confirmation code on create' do
        merchant = create(:merchant, name: 'Test Merchant')
        order = build(:order, merchant: merchant, confirmation_code: nil)
        order.save!

        expect(order.confirmation_code).to be_present
        expect(order.confirmation_code).to match(/^TE\d{4}$/)
      end

      it 'does not regenerate confirmation code on update' do
        order = create(:order)
        original_code = order.confirmation_code

        order.update!(status: 'confirmed')
        expect(order.confirmation_code).to eq(original_code)
      end

      it 'generates unique confirmation codes' do
        merchant = create(:merchant, name: 'Test Merchant')
        order1 = create(:order, merchant: merchant)
        order2 = create(:order, merchant: merchant)

        expect(order1.confirmation_code).not_to eq(order2.confirmation_code)
      end

      it 'handles merchant names with special characters' do
        merchant = create(:merchant, name: 'Café & Bakery')
        order = create(:order, merchant: merchant)

        expect(order.confirmation_code).to start_with('CA')
      end

      it 'generates code even for single character merchant names' do
        merchant = create(:merchant, name: 'A')
        order = create(:order, merchant: merchant)

        expect(order.confirmation_code).to match(/^A\d{4}$/)
      end
    end
  end

  describe 'scopes' do
    let!(:merchant) { create(:merchant) }
    let!(:customer) { create(:customer) }
    let!(:pending_order) { create(:order, :pending, customer: customer, merchant: merchant) }
    let!(:confirmed_order) { create(:order, :confirmed, customer: customer, merchant: merchant) }
    let!(:preparing_order) { create(:order, :preparing, customer: customer, merchant: merchant) }
    let!(:ready_order) { create(:order, :ready, customer: customer, merchant: merchant) }
    let!(:completed_order) { create(:order, :completed, customer: customer, merchant: merchant) }
    let!(:cancelled_order) { create(:order, :cancelled, customer: customer, merchant: merchant) }
    let!(:today_order) { create(:order, :pickup_today, customer: customer, merchant: merchant) }

    describe '.active' do
      it 'returns orders with active status' do
        active_orders = Order.active
        expect(active_orders).to include(pending_order, confirmed_order, preparing_order, ready_order)
        expect(active_orders).not_to include(completed_order, cancelled_order)
      end
    end

    describe '.completed' do
      it 'returns only completed orders' do
        completed_orders = Order.completed
        expect(completed_orders).to include(completed_order)
        expect(completed_orders).not_to include(pending_order, confirmed_order, preparing_order, ready_order, cancelled_order)
      end
    end

    describe '.for_pickup_today' do
      it 'returns orders scheduled for pickup today' do
        pickup_today_orders = Order.for_pickup_today
        expect(pickup_today_orders).to include(today_order)
        # Other orders may or may not be included depending on their pickup times
      end
    end
  end

  describe 'instance methods' do
    describe '#completed?' do
      it 'returns true for completed orders' do
        order = build(:order, status: 'completed')
        expect(order.completed?).to be true
      end

      it 'returns false for non-completed orders' do
        %w[pending confirmed preparing ready cancelled].each do |status|
          order = build(:order, status: status)
          expect(order.completed?).to be false
        end
      end
    end

    describe '#can_be_picked_up?' do
      it 'returns true for ready orders within pickup window' do
        order = build(:order,
          status: 'ready',
          pickup_window_start: 30.minutes.ago,
          pickup_window_end: 2.hours.from_now
        )
        expect(order.can_be_picked_up?).to be true
      end

      it 'returns false for non-ready orders' do
        %w[pending confirmed preparing completed cancelled].each do |status|
          order = build(:order,
            status: status,
            pickup_window_start: 30.minutes.ago,
            pickup_window_end: 2.hours.from_now
          )
          expect(order.can_be_picked_up?).to be false
        end
      end

      it 'returns false for ready orders before pickup window' do
        order = build(:order,
          status: 'ready',
          pickup_window_start: 1.hour.from_now,
          pickup_window_end: 3.hours.from_now
        )
        expect(order.can_be_picked_up?).to be false
      end

      it 'returns false for ready orders after pickup window' do
        order = build(:order,
          status: 'ready',
          pickup_window_start: 3.hours.ago,
          pickup_window_end: 1.hour.ago
        )
        expect(order.can_be_picked_up?).to be false
      end

      it 'returns true for ready orders exactly at pickup window start' do
        travel_to(Time.current) do
          order = build(:order,
            status: 'ready',
            pickup_window_start: Time.current,
            pickup_window_end: 2.hours.from_now
          )
          expect(order.can_be_picked_up?).to be true
        end
      end

      it 'returns true for ready orders exactly at pickup window end' do
        travel_to(Time.current) do
          order = build(:order,
            status: 'ready',
            pickup_window_start: 1.hour.ago,
            pickup_window_end: Time.current
          )
          expect(order.can_be_picked_up?).to be true
        end
      end
    end

    describe '#overdue?' do
      it 'returns true for orders past pickup window and not completed' do
        %w[pending confirmed preparing ready cancelled].each do |status|
          order = build(:order,
            status: status,
            pickup_window_end: 1.hour.ago
          )
          expect(order.overdue?).to be true
        end
      end

      it 'returns false for completed orders even if past pickup window' do
        order = build(:order,
          status: 'completed',
          pickup_window_end: 1.hour.ago
        )
        expect(order.overdue?).to be false
      end

      it 'returns false for orders within pickup window' do
        order = build(:order,
          status: 'ready',
          pickup_window_end: 1.hour.from_now
        )
        expect(order.overdue?).to be false
      end

      it 'returns false for orders exactly at pickup window end' do
        travel_to(Time.current) do
          order = build(:order,
            status: 'ready',
            pickup_window_end: Time.current
          )
          expect(order.overdue?).to be false
        end
      end
    end

    describe '#calculate_total!' do
      let!(:order) { create(:order, total_amount: 0) }
      let!(:order_item1) { create(:order_item, order: order, price_at_purchase: 10.00, quantity: 2) }
      let!(:order_item2) { create(:order_item, order: order, price_at_purchase: 15.50, quantity: 1) }
      let!(:order_item3) { create(:order_item, order: order, price_at_purchase: 8.75, quantity: 3) }

      it 'calculates total amount from order items' do
        order.calculate_total!
        # (10.00 * 2) + (15.50 * 1) + (8.75 * 3) = 20.00 + 15.50 + 26.25 = 61.75
        expect(order.total_amount).to eq(61.75)
      end

      it 'saves the calculated total to database' do
        expect { order.calculate_total! }.to change { order.reload.total_amount }
      end

      it 'handles orders with no items' do
        empty_order = create(:order, total_amount: 100.00)
        empty_order.calculate_total!
        expect(empty_order.total_amount).to eq(0.00)
      end

      it 'handles decimal calculations correctly' do
        order.order_items.destroy_all
        create(:order_item, order: order, price_at_purchase: 3.33, quantity: 3)
        order.calculate_total!
        expect(order.total_amount).to eq(9.99)
      end
    end
  end

  describe 'complex business scenarios' do
    let!(:merchant) { create(:merchant) }
    let!(:customer) { create(:customer) }

    context 'order lifecycle' do
      it 'can progress through normal order states' do
        order = create(:order, customer: customer, merchant: merchant, status: 'pending')

        order.update!(status: 'confirmed')
        expect(order.status).to eq('confirmed')

        order.update!(status: 'preparing')
        expect(order.status).to eq('preparing')

        order.update!(status: 'ready')
        expect(order.status).to eq('ready')

        order.update!(status: 'completed')
        expect(order.status).to eq('completed')
        expect(order.completed?).to be true
      end

      it 'can be cancelled at any stage' do
        %w[pending confirmed preparing ready].each do |status|
          order = create(:order, customer: customer, merchant: merchant, status: status)
          order.update!(status: 'cancelled')
          expect(order.status).to eq('cancelled')
        end
      end
    end

    context 'order with items integration' do
      it 'calculates total correctly with mixed item types' do
        order = create(:order, customer: customer, merchant: merchant)
        product = create(:product, merchant: merchant, discounted_price: 12.50)
        bundle = create(:bundle, merchant: merchant, bundle_price: 25.00)

        create(:order_item, :product_item, order: order, item_id: product.id,
               price_at_purchase: product.discounted_price, quantity: 2)
        create(:order_item, :bundle_item, order: order, item_id: bundle.id,
               price_at_purchase: bundle.bundle_price, quantity: 1)

        order.calculate_total!
        # (12.50 * 2) + (25.00 * 1) = 25.00 + 25.00 = 50.00
        expect(order.total_amount).to eq(50.00)
      end
    end
  end

  describe 'edge cases' do
    it 'handles very large total amounts' do
      order = build(:order, total_amount: 999999.99)
      expect(order).to be_valid
    end

    it 'handles orders with far future pickup times' do
      order = build(:order,
        pickup_window_start: 1.month.from_now,
        pickup_window_end: 1.month.from_now + 2.hours
      )
      expect(order).to be_valid
    end

    it 'handles merchant name edge cases for confirmation code' do
      merchant = create(:merchant, name: '')
      order = build(:order, merchant: merchant)
      expect { order.save! }.not_to raise_error
    end
  end

  describe 'factory traits' do
    it 'creates orders with different statuses' do
      confirmed = create(:order, :confirmed)
      expect(confirmed.status).to eq('confirmed')

      ready = create(:order, :ready)
      expect(ready.status).to eq('ready')

      completed = create(:order, :completed)
      expect(completed.status).to eq('completed')
    end

    it 'creates overdue orders' do
      overdue = create(:order, :overdue)
      expect(overdue.overdue?).to be true
    end

    it 'creates orders that can be picked up' do
      pickup_ready = create(:order, :can_be_picked_up)
      expect(pickup_ready.can_be_picked_up?).to be true
    end

    it 'creates orders with order items' do
      order = create(:order, :with_order_items)
      expect(order.order_items.count).to be >= 1
      expect(order.total_amount).to be > 0
    end
  end

  describe 'factory' do
    it 'creates valid order' do
      expect(build(:order)).to be_valid
    end

    it 'generates unique confirmation codes' do
      order1 = create(:order)
      order2 = create(:order)
      expect(order1.confirmation_code).not_to eq(order2.confirmation_code)
    end

    it 'ensures pickup_window_end is after pickup_window_start' do
      order = create(:order)
      expect(order.pickup_window_end).to be > order.pickup_window_start
    end
  end
end
