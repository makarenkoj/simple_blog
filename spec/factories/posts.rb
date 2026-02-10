FactoryBot.define do
  factory :post do
    association :user
    title { Faker::Book.title } 
    body { Faker::Lorem.paragraphs(number: 3).join("\n\n") }

    trait :with_image do
      after(:build) do |post|
        # Перевіряємо, чи існує файл, щоб не падало з помилкою
        file_path = Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')
        
        if File.exist?(file_path)
          post.cover_image.attach(
            io: File.open(file_path),
            filename: 'test_image.jpg',
            content_type: 'image/jpeg'
          )
        else
          puts "⚠️ Увага: Файл test_image.jpg не знайдено в spec/fixtures/files/"
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
