FactoryBot.define do
  factory :bundle_item do
    association :bundle
    association :product
    quantity { rand(1..5) }

    # Ensure the product belongs to the same merchant as the bundle
    after(:build) do |bundle_item|
      if bundle_item.bundle && !bundle_item.product&.merchant_id
        bundle_item.product = create(:product, merchant: bundle_item.bundle.merchant)
      end
    end

    trait :single_item do
      quantity { 1 }
    end

    trait :multiple_items do
      quantity { rand(3..8) }
    end
  end
end
