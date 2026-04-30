namespace :sitemap do
  desc "Refresh sitemap with proper URL configuration"
  task refresh: :environment do
    unless ENV['DEFAULT_HOST'].present?
      puts "WARNING: DEFAULT_HOST не встановлений, використовую localhost"
      ENV['DEFAULT_HOST'] = 'localhost:3000'
    end

    host = ENV.fetch('DEFAULT_HOST')
    protocol = Rails.env.production? ? 'https' : 'http'

    Rails.application.routes.default_url_options = { host: host, protocol: protocol }
    ActionController::Base.default_url_options = { host: host, protocol: protocol }

    puts "Generating sitemap for #{protocol}://#{host}..."

    Rake::Task['sitemap:create'].invoke

    puts "Sitemap generated successfully!"
  end
end
