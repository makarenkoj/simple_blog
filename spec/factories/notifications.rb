FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user
    association :notifiable, factory: :user 
    action { "new_follower" }
    read { false }

    trait :read do
      read { true }
    end
  end
end
