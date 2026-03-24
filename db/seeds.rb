# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'open-uri'
require 'faker'

if env['RAILS_ENV'] == 'development'
  puts "⚠️  You are running seeds in development environment. Make sure you have the right database configured!"
  puts 'Seeding categories...'
  puts "Creating Categories with images..."
  puts "📂 Створення категорій..."

  # categories_list = [
  #   { name: 'Technology', query: 'technology,computer' },
  #   { name: 'Travel', query: 'travel,nature' },
  #   { name: 'Food', query: 'food,cooking' },
  #   { name: 'Lifestyle', query: 'lifestyle,people' },
  #   { name: 'Health', query: 'health,fitness' },
  #   { name: 'Fashion', query: 'fashion,style' },
  #   { name: 'Business', query: 'business,office' },
  #   { name: 'Education', query: 'education,book' },
  #   { name: 'Sports', query: 'sports,game' },
  #   { name: 'Art', query: 'art,painting' },
  #   { name: 'Music', query: 'music,concert' },
  #   { name: 'Cinema', query: 'cinema,movie' }
  # ]

  created_categories = []

  # categories_list.each do |cat_data|
  #   category = Category.find_or_create_by!(name: cat_data[:name].downcase)
  #   created_categories << category
    
  #   unless category.cover_image.attached?
  #     puts "  - Downloading image for #{cat_data[:name]}..."
  #     begin
  #       image_url = "https://loremflickr.com/320/320/#{cat_data[:name].downcase}/all" 
  #       downloaded_image = URI.open(image_url)
  #       category.cover_image.attach(io: downloaded_image, filename: "#{cat_data[:name].downcase}.jpg")
  #       print "."
  #     rescue => e
  #       puts "\n⚠️ Не вдалося завантажити фото для категорії #{cat_data[:name]}: #{e.message}"
  #     end
  #   end
  # end

  # puts "\n✅ Створено #{Category.count} категорій."

  # puts "👤 Створення вашого користувача..."
  # main_user = User.create!(
  #   email: 'admin@example.com',
  #   password: 'password',
  #   password_confirmation: 'password',
  #   username: 'SuperAdmin',
  #   first_name: 'Max',
  #   last_name: 'Admin',
  #   role: :creator
  # )
  # puts "✅ Користувач admin@example.com (пароль: password) створений."

  # puts "✍️ Створення авторів..."
  # creators = []

  # 10.times do |i|
  #   first_name = Faker::Name.first_name
  #   last_name = Faker::Name.last_name
  #   clean_first = first_name.gsub(/[^a-zA-Z0-9]/, '')
  #   clean_last = last_name.gsub(/[^a-zA-Z0-9]/, '')
  #   base_username = "#{clean_first}_#{clean_last}".downcase
  #   base_username = base_username[0...20]
  #   base_username = "user_#{base_username}" if base_username.length < 3
  #   username = base_username
  #   counter = 1

  #   while User.exists?(username: username)
  #     username = "#{base_username[0...(19 - counter.to_s.length)]}#{counter}"
  #     counter += 1
  #   end

  #   user = User.create!(
  #     email: Faker::Internet.unique.email,
  #     password: 'password',
  #     username: username,
  #     first_name: first_name,
  #     last_name: last_name,
  #     role: :creator
  #   )
  #   creators << user

  #   begin
  #     avatar_url = "https://ui-avatars.com/api/?name=#{first_name}+#{last_name}&background=random&size=200"
  #     downloaded_avatar = URI.open(avatar_url)
  #     user.avatar.attach(io: downloaded_avatar, filename: "avatar_#{i}.png", content_type: 'image/png')
  #   rescue => e
  #     puts "⚠️ Не вдалося завантажити аватар: #{e.message}"
  #   end
  # end
  # puts "\n✅ Створено 10 авторів."

  # puts "👀 Створення читачів..."
  # 5.times do
  #   User.create!(
  #     email: Faker::Internet.unique.email,
  #     password: 'password',
  #     username: Faker::Internet.unique.username,
  #     first_name: Faker::Name.first_name,
  #     last_name: Faker::Name.last_name,
  #     role: :reader
  #   )
  # end

  # puts "✅ Створено 5 читачів."
  # puts "📝 Написання постів..."

  creators = User.creator

  Category.all.each do |c|
    created_categories << c
  end

  creators.each do |creator|
    rand(3..5).times do
      target_category = created_categories.sample
      post = Post.new(
        title: Faker::Book.title,
        user: creator
      )

      body_content = "<div><p>#{Faker::Lorem.paragraph(sentence_count: 5)}</p><h3>#{Faker::Lorem.sentence}</h3><p>#{Faker::Lorem.paragraph(sentence_count: 10)}</p></div>"
      post.body = body_content

      post.save!

      post.categories << target_category
      post.categories << created_categories.sample if [true, false].sample && created_categories.sample != target_category

      begin
        query_term = target_category.name.downcase
        image_url = "https://loremflickr.com/800/600/#{query_term}/all"
        downloaded_image = URI.open(image_url)
        post.cover_image.attach(io: downloaded_image, filename: "post_#{post.id}.jpg", content_type: 'image/jpeg')
        print "."
      rescue => e
        puts "\n⚠️ Не вдалося завантажити обкладинку поста: #{e.message}"
      end
    end
  end

  puts "\n✅ Створено #{Post.count} постів."
  puts "❤️ Налаштування підписок..."

  User.all.each do |user|
    creators.sample(rand(2..5)).each do |creator|
      next if user == creator # не підписуватись на себе
      user.follow(creator) unless user.following?(creator)
    end

    created_categories.sample(rand(2..4)).each do |cat|
      user.preferred_categories << cat unless user.preferred_categories.include?(cat)
    end
  end

  puts "✅ Підписки створено."
  puts "🎉 SEED COMPLETED! Можна запускати сервер."
  puts "Done!"
  puts 'Categories seeded successfully.'
elsif env['RAILS_ENV'] == 'production'
  puts "⚠️  You are running seeds in PRODUCTION environment. Be careful!"
end
