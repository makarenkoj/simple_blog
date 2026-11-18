# The one place that decides which HTML a post body may render (posts are written in
# Tiptap and stored as HTML in posts.body_html). Iframes are allowed only as
# privacy-enhanced YouTube embeds; every other frame is removed.
class PostBodySanitizer
  TAGS = %w[
    p br strong em u s
    h1 h2 h3 h4 h5 h6
    ul ol li
    blockquote
    pre code
    table thead tbody tr td th
    a img
    span
    iframe
  ].freeze
  ATTRIBUTES = %w[href src class colspan rowspan style width height allowfullscreen].freeze
  YOUTUBE_EMBED = %r{\Ahttps://www\.youtube-nocookie\.com/embed/[A-Za-z0-9_-]{11}(\?[A-Za-z0-9_=&-]*)?\z}

  # Output is marked html_safe because it has just been through the safe-list sanitizer,
  # exactly as Rails' own `sanitize` helper does.
  # rubocop:disable Rails/OutputSafety
  def self.call(html)
    safe = Rails::HTML::Sanitizer.best_supported_vendor.safe_list_sanitizer.new
                                 .sanitize(html.to_s, tags: TAGS, attributes: ATTRIBUTES)
    return safe.html_safe unless safe.include?('<iframe')

    fragment = Loofah.html5_fragment(safe)
    fragment.css('iframe').each { |frame| frame.remove unless YOUTUBE_EMBED.match?(frame['src'].to_s) }
    fragment.to_s.html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
