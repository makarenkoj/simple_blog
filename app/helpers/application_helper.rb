module ApplicationHelper
  def link_to_switch_locale
    current_locale_index = I18n.available_locales.find_index(I18n.locale)
    next_locale = I18n.available_locales[(current_locale_index + 1) % I18n.available_locales.length]

    country_code = next_locale.to_s.split('-').last.downcase
    country_code = 'us' if country_code == 'en' # TODO: Why?

    link_to({ locale: next_locale }, title: t('views.switch_locale', locale: next_locale)) do
      tag.span(class: "flag-icon-background flag-icon-#{country_code} nav-link")
    end
  end

  def emoji_flag(country_code)
    cc = country_code.to_s.upcase
    return unless cc =~ /\A[A-Z]{2}\z/

    cc.codepoints.map { |c| (c + 127_397).chr(Encoding::UTF_8) }.join
  end

  def flash_class(level)
    case level.to_sym
    when :notice then 'bg-green-100 text-green-800'
    when :success then 'bg-green-100 text-green-800'
    when :error then 'bg-red-100 text-red-800'
    when :alert then 'bg-red-100 text-red-800'
    else 'bg-gray-100 text-gray-700 border border-gray-400'
    end
  end
end
