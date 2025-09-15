FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    phone { Faker::PhoneNumber.phone_number }
    preferred_radius { rand(1..25) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    address { Faker::Address.full_address }
    dietary_preferences {
      {
        "allergies" => ["nuts", "dairy"].sample(rand(0..2)),
        "preferences" => ["vegetarian", "vegan", "gluten-free"].sample(rand(0..2)),
        "avoid" => ["spicy", "seafood"].sample(rand(0..1))
      }
    }

    trait :with_no_dietary_restrictions do
      dietary_preferences { {} }
    end

    trait :vegetarian do
      dietary_preferences {
        {
          "preferences" => ["vegetarian"],
          "avoid" => ["meat", "fish"]
        }
      }
    end

    trait :with_allergies do
      dietary_preferences {
        {
          "allergies" => ["nuts", "dairy", "eggs"]
        }
      }
    end

    trait :nearby_san_francisco do
      latitude { 37.7749 }
      longitude { -122.4194 }
      address { "San Francisco, CA" }
    end
  end
end
