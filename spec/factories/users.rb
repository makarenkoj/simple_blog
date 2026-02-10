FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "tester#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    first_name { Faker::Name.first_name_men }
    last_name { Faker::Name.last_name }
    password { 'password123' }
    role { :reader }

    trait :creator do
      role { :creator }
    end
  end
end
