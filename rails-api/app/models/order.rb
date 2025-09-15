class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :order_items, dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w[pending confirmed preparing ready completed cancelled] }
  validates :confirmation_code, presence: true, uniqueness: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :pickup_window_start, :pickup_window_end, presence: true
  validate :pickup_window_end_after_start

  scope :active, -> { where(status: %w[pending confirmed preparing ready]) }
  scope :completed, -> { where(status: 'completed') }
  scope :for_pickup_today, -> { where(pickup_window_start: Date.current.beginning_of_day..Date.current.end_of_day) }

  before_validation :generate_confirmation_code, on: :create

  def completed?
    status == 'completed'
  end

  def can_be_picked_up?
    %w[ready].include?(status) && pickup_window_start <= Time.current && pickup_window_end >= Time.current
  end

  def overdue?
    pickup_window_end < Time.current && !completed?
  end

  def calculate_total!
    self.total_amount = order_items.sum { |item| item.price * item.quantity }
    save!
  end

  private

  def pickup_window_end_after_start
    return unless pickup_window_start && pickup_window_end

    errors.add(:pickup_window_end, 'must be after pickup window start') if pickup_window_end <= pickup_window_start
  end

  def generate_confirmation_code
    loop do
      self.confirmation_code = "#{merchant.name.first(2).upcase}#{rand(1000..9999)}"
      break unless Order.exists?(confirmation_code: confirmation_code)
    end
  end
end
