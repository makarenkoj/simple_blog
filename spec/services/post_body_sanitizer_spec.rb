require 'rails_helper'

RSpec.describe PostBodySanitizer do
  include_context 'base'

  def clean(html) = described_class.call(html)

  # Pin: what posts.show rendered before the sanitizer moved out of the view.
  it 'renders existing post bodies exactly as before' do
    legacy = ActionController::Base.helpers.sanitize(
      valid_body_html,
      tags: %w[p br strong em u s h1 h2 h3 h4 h5 h6 ul ol li blockquote pre code
               table thead tbody tr td th a img span],
      attributes: %w[href src class colspan rowspan style]
    )

    expect(clean(valid_body_html)).to eq(legacy)
  end

  it 'keeps tables with merged cells' do
    html = '<table><tbody><tr><th colspan="2">Head</th></tr><tr><td rowspan="1">a</td><td>b</td></tr></tbody></table>'

    expect(clean(html)).to eq(html)
  end

  it 'keeps the language of a code block for highlighting' do
    html = '<pre><code class="language-ruby">puts 1</code></pre>'

    expect(clean(html)).to eq(html)
  end

  describe 'YouTube embeds' do
    let(:embed) do
      '<div data-youtube-video=""><iframe src="https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ" ' \
        'width="640" height="360" allowfullscreen="true"></iframe></div>'
    end

    it 'keeps a privacy-enhanced YouTube embed' do
      out = Nokogiri::HTML5.fragment(clean(embed)).at_css('iframe')

      expect(out).to be_present
      expect(out['src']).to eq('https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ')
      expect(out['allowfullscreen']).to be_present
    end

    it 'drops iframes pointing anywhere else' do
      [
        'https://evil.example/embed/x',
        'https://www.youtube.com.evil.example/embed/x',
        'http://www.youtube-nocookie.com/embed/dQw4w9WgXcQ',
        'https://www.youtube-nocookie.com/embed/x?autoplay=1"><script>',
        'javascript:alert(1)',
        '//www.youtube-nocookie.com/embed/dQw4w9WgXcQ'
      ].each do |src|
        expect(clean(%(<iframe src="#{src}"></iframe>))).not_to include('<iframe'), src
      end
    end

    it 'drops iframe attributes that could script or escape the frame' do
      html = '<iframe src="https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ" srcdoc="<script>x</script>" ' \
             'onload="alert(1)" sandbox=""></iframe>'
      out = clean(html)

      expect(out).to include('<iframe')
      expect(out).not_to match(/srcdoc|onload|sandbox/)
    end
  end

  it 'still strips scripts and event handlers' do
    out = clean('<p onclick="x()">hi</p><script>alert(1)</script><img src="x" onerror="alert(1)">')

    expect(out).not_to match(/script|onclick|onerror/)
  end
end
