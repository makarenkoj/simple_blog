# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'open-uri'

puts 'Seeding categories...'

puts "Creating Categories with images..."

categories_list = [
  'Technology', 'Travel', 'Food', 'Lifestyle', 'Health', 
  'Fashion', 'Finance', 'Education', 'Sports', 'Art'
]

categories_list.each do |cat_name|
  category = Category.find_or_create_by!(name: cat_name.downcase)

  unless category.cover_image.attached?
    puts "  - Downloading image for #{cat_name}..."

    image_url = "https://loremflickr.com/320/320/#{cat_name.downcase}/all" 

    begin
      downloaded_image = URI.open(image_url)
      category.cover_image.attach(io: downloaded_image, filename: "#{cat_name.downcase}.jpg")
    rescue => e
      puts "    Failed to attach image for #{cat_name}: #{e.message}"
    end
  end
end

puts "Done!"
puts 'Categories seeded successfully.'
