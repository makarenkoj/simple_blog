FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "#{Faker::Coffee.blend_name} #{n}" }
  end
end
