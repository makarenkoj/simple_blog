module ApplicationHelper
  def link_to_switch_locale
    current_locale_index = I18n.available_locales.find_index(I18n.locale)
    next_locale = I18n.available_locales[(current_locale_index + 1) % I18n.available_locales.length]

    country_code = next_locale.to_s.split('-').last.downcase
    country_code = 'us' if country_code == 'en'

    link_to %{<span class="flag-icon-background flag-icon-#{country_code} nav-link"></span>}.html_safe,
            {locale: next_locale},
            title: t('views.switch_locale', locale: next_locale)
  end
end
