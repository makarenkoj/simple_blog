FactoryBot.define do
  factory :post do
    association :user
    title { Faker::Book.title } 
    body { Faker::Lorem.paragraphs(number: 3).join("\n\n") }

    trait :with_image do
      after(:build) do |post|
        file_path = Rails.root.join('spec', 'fixtures', 'files', 'valid_image.png')

        if File.exist?(file_path)
          post.cover_image.attach(
            io: File.open(file_path),
            filename: 'valid_image.png',
            content_type: 'image/png'
          )
        else
          puts "⚠️ Увага: Файл valid_image.png не знайдено в spec/fixtures/files/"
        end
      end
    end

    trait :with_categories do
      transient do
        categories_count { 2 }
      end

      after(:create) do |post, evaluator|
        create_list(:category, evaluator.categories_count, posts: [post])
      end
    end

    trait :published do
      created_at { 1.day.ago }
      updated_at { 1.day.ago }
    end
  end
end
