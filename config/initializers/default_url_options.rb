unless Rails.env.test?
  Rails.application.configure do
    host = ENV.fetch('DEFAULT_HOST') { 
      Rails.env.production? ? 'helpbooost.com' : 'localhost:3000' 
    }

    protocol = Rails.env.production? ? 'https' : 'http'
    config.action_mailer.default_url_options = { host: host, protocol: protocol }

    config.after_initialize do
      Rails.application.routes.default_url_options = { host: host, protocol: protocol }
      ActionController::Base.default_url_options = { host: host, protocol: protocol }

      if defined?(ActiveStorage)
        ActiveStorage::Current.url_options = { host: host, protocol: protocol }
      end
    end
  end
end
