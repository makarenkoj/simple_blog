I18n.load_path += Dir[Rails.root.join('lib/locale/*.{rb,yml}')]

I18n.available_locales = %i[en uk]

I18n.default_locale = :uk
