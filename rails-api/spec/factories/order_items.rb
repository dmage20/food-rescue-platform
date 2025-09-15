FactoryBot.define do
  factory :order_item do
    association :order
    item_type { "product" }
    quantity { rand(1..5) }
    name { Faker::Food.dish }
    price_at_purchase { rand(5.00..50.00).round(2) }

    # Create item_id based on item_type
    after(:build) do |order_item|
      case order_item.item_type
      when "product"
        product = create(:product, merchant: order_item.order.merchant)
        order_item.item_id = product.id
        order_item.name = product.name
        order_item.price_at_purchase = product.discounted_price
      when "bundle"
        bundle = create(:bundle, merchant: order_item.order.merchant)
        order_item.item_id = bundle.id
        order_item.name = bundle.name
        order_item.price_at_purchase = bundle.bundle_price
      end
    end

    trait :product_item do
      item_type { "product" }
    end

    trait :bundle_item do
      item_type { "bundle" }
    end

    trait :single_quantity do
      quantity { 1 }
    end

    trait :multiple_quantity do
      quantity { rand(3..8) }
    end

    trait :expensive_item do
      price_at_purchase { rand(25.00..75.00).round(2) }
    end

    trait :cheap_item do
      price_at_purchase { rand(2.00..15.00).round(2) }
    end
  end
end
