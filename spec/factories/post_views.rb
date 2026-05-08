FactoryBot.define do
  factory :post_view do
    association :post
    user { nil }
    ip_address { 'MyString' }

    trait :with_user do
      association :user
    end
  end
end
