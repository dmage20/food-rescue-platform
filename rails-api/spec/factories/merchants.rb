FactoryBot.define do
  factory :merchant do
    name { Faker::Company.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.full_address }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
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
  end
end
