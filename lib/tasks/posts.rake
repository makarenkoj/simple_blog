namespace :posts do
  desc "Migrate ActionText content to TipTap HTML"
  task migrate_to_tiptap: :environment do
    Post.find_each do |post|
      next unless post.body.present?

      html = post.body.body.to_s

      post.update_column(:body_html, html)

      puts "Migrated post ID: #{post.id}"
    end
  end
end
