module ShareHelper
  def share_url(provider, url, title)
    escaped_url = CGI.escape(url)
    escaped_title = CGI.escape(title)

    case provider
    when :twitter
      "https://twitter.com/intent/tweet?url=#{escaped_url}&text=#{escaped_title}"
    when :facebook
      "https://www.facebook.com/sharer/sharer.php?u=#{escaped_url}"
    when :telegram
      "https://t.me/share/url?url=#{escaped_url}&text=#{escaped_title}"
    when :linkedin
      "https://www.linkedin.com/shareArticle?mini=true&url=#{escaped_url}&title=#{escaped_title}"
    when :whatsapp
      "https://wa.me/?text=#{escaped_title}%20#{escaped_url}"
    else
      '#'
    end
  end
end
