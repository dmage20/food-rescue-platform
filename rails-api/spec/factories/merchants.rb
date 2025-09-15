FactoryBot.define do
  factory :merchant do
    name { Faker::Company.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.full_address }
    latitude { Faker::Address.latitude.to_f }
    longitude { Faker::Address.longitude.to_f }
    business_hours {
      {
        "monday" => { "open" => "09:00", "close" => "17:00" },
        "tuesday" => { "open" => "09:00", "close" => "17:00" },
        "wednesday" => { "open" => "09:00", "close" => "17:00" },
        "thursday" => { "open" => "09:00", "close" => "17:00" },
        "friday" => { "open" => "09:00", "close" => "17:00" },
        "saturday" => { "open" => "10:00", "close" => "16:00" },
        "sunday" => { "open" => "closed", "close" => "closed" }
      }
    }
    pickup_instructions { Faker::Lorem.sentence }
    specialty { Faker::Food.dish }
    password { "password123" }

    trait :with_products do
      after(:create) do |merchant|
        create_list(:product, 5, merchant: merchant)
      end
    end

    trait :with_bundles do
      after(:create) do |merchant|
        create_list(:bundle, 3, merchant: merchant)
      end
    end

    trait :san_francisco do
      address { "San Francisco, CA" }
      latitude { 37.7749 }
      longitude { -122.4194 }
    end

    trait :los_angeles do
      address { "Los Angeles, CA" }
      latitude { 34.0522 }
      longitude { -118.2437 }
    end

    trait :closed_sundays do
      business_hours {
        {
          "monday" => { "open" => "09:00", "close" => "17:00" },
          "tuesday" => { "open" => "09:00", "close" => "17:00" },
          "wednesday" => { "open" => "09:00", "close" => "17:00" },
          "thursday" => { "open" => "09:00", "close" => "17:00" },
          "friday" => { "open" => "09:00", "close" => "17:00" },
          "saturday" => { "open" => "10:00", "close" => "16:00" },
          "sunday" => { "open" => "closed", "close" => "closed" }
        }
      }
    end
  end
end
