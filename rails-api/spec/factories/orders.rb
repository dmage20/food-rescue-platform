FactoryBot.define do
  factory :order do
    association :customer
    association :merchant
    status { "pending" }
    total_amount { rand(10.00..100.00).round(2) }
    pickup_window_start { rand(1..6).hours.from_now }
    pickup_window_end { pickup_window_start + rand(1..3).hours }
    special_instructions { Faker::Lorem.sentence }

    trait :confirmed do
      status { "confirmed" }
    end

    trait :preparing do
      status { "preparing" }
    end

    trait :ready do
      status { "ready" }
    end

    trait :completed do
      status { "completed" }
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :overdue do
      pickup_window_start { 3.hours.ago }
      pickup_window_end { 1.hour.ago }
    end

    trait :pickup_today do
      pickup_window_start { rand(0..8).hours.from_now.beginning_of_day + rand(8..20).hours }
      pickup_window_end { pickup_window_start + rand(1..2).hours }
    end

    trait :can_be_picked_up do
      status { "ready" }
      pickup_window_start { 30.minutes.ago }
      pickup_window_end { 2.hours.from_now }
    end

    trait :with_order_items do
      after(:create) do |order|
        create_list(:order_item, rand(1..4), order: order)
        order.calculate_total!
      end
    end

    trait :high_value do
      total_amount { rand(75.00..200.00).round(2) }
    end

    trait :low_value do
      total_amount { rand(5.00..25.00).round(2) }
    end
  end
end
