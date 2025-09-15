FactoryBot.define do
  factory :bundle do
    association :merchant
    name { "#{Faker::Food.dish} Bundle" }
    description { Faker::Food.description }
    total_original_price { rand(15.00..75.00).round(2) }
    discount_percentage { rand(25..60) }
    available_quantity { rand(1..10) }
    expires_at { rand(2.hours..24.hours).from_now }

    # Calculate bundle_price based on total_original_price and discount_percentage
    bundle_price { (total_original_price * (1 - discount_percentage / 100.0)).round(2) }

    trait :expired do
      expires_at { rand(1.hour..5.hours).ago }
    end

    trait :expiring_soon do
      expires_at { rand(30.minutes..90.minutes).from_now }
    end

    trait :out_of_stock do
      available_quantity { 0 }
    end

    trait :high_value do
      total_original_price { rand(50.00..100.00).round(2) }
    end

    trait :low_value do
      total_original_price { rand(10.00..25.00).round(2) }
    end

    trait :high_discount do
      discount_percentage { rand(50..70) }
    end

    trait :low_discount do
      discount_percentage { rand(15..30) }
    end

    # Create bundle with associated products
    trait :with_products do
      after(:create) do |bundle|
        products = create_list(:product, 3, merchant: bundle.merchant)
        products.each_with_index do |product, index|
          create(:bundle_item, bundle: bundle, product: product, quantity: index + 1)
        end

        # Update total_original_price based on actual products
        actual_total = bundle.bundle_items.sum { |bi| bi.product.original_price * bi.quantity }
        bundle.update!(total_original_price: actual_total)
        bundle.update!(bundle_price: (actual_total * (1 - bundle.discount_percentage / 100.0)).round(2))
      end
    end
  end
end
