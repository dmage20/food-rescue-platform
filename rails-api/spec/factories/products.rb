FactoryBot.define do
  factory :product do
    association :merchant
    name { Faker::Food.dish }
    description { Faker::Food.description }
    category { ["bakery", "prepared_food", "produce", "dairy", "meat", "seafood", "pantry"].sample }
    original_price { rand(5.00..50.00).round(2) }
    discount_percentage { rand(20..80) }
    available_quantity { rand(1..20) }
    expires_at { rand(2.hours..48.hours).from_now }
    allergens { ["nuts", "dairy", "gluten", "eggs", "soy"].sample(rand(0..3)) }
    ingredients { Faker::Food.ingredient }
    nutritional_info {
      {
        "calories" => rand(100..800),
        "protein" => rand(5..50),
        "carbs" => rand(10..100),
        "fat" => rand(2..30)
      }
    }

    # Calculate discounted_price based on original_price and discount_percentage
    discounted_price { (original_price * (1 - discount_percentage / 100.0)).round(2) }

    trait :expired do
      expires_at { rand(1.hour..5.hours).ago }
    end

    trait :expiring_soon do
      expires_at { rand(30.minutes..90.minutes).from_now }
    end

    trait :out_of_stock do
      available_quantity { 0 }
    end

    trait :bakery do
      category { "bakery" }
      name { Faker::Dessert.variety }
      allergens { ["gluten", "eggs", "dairy"] }
    end

    trait :produce do
      category { "produce" }
      name { Faker::Food.fruits }
      allergens { [] }
    end

    trait :high_discount do
      discount_percentage { rand(60..80) }
    end

    trait :low_discount do
      discount_percentage { rand(10..25) }
    end

    trait :expensive do
      original_price { rand(25.00..75.00).round(2) }
    end

    trait :cheap do
      original_price { rand(2.00..10.00).round(2) }
    end
  end
end
