require 'rails_helper'

# One Markdown -> HTML converter for the API and the editor import (SAM1-29). Its output is
# stored in posts.body_html and later rendered through PostBodySanitizer.
RSpec.describe MarkdownToHtml do
  def html(markdown) = described_class.call(markdown)
  def doc(markdown) = Nokogiri::HTML5.fragment(html(markdown))

  it 'converts headings, emphasis, lists and links' do
    out = doc("## Title\n\nSome **bold** and *italic* text.\n\n- one\n- two\n\n[site](https://example.com)")

    aggregate_failures do
      expect(out.at_css('h2').text).to eq('Title')
      expect(out.at_css('strong').text).to eq('bold')
      expect(out.at_css('em').text).to eq('italic')
      expect(out.css('ul li').map(&:text)).to eq(%w[one two])
      expect(out.at_css('a')['href']).to eq('https://example.com')
    end
  end

  it 'converts GitHub tables' do
    out = doc("| Lang | Type |\n|---|---|\n| Ruby | Dynamic |")

    expect(out.css('th').map(&:text)).to eq(%w[Lang Type])
    expect(out.css('td').map(&:text)).to eq(%w[Ruby Dynamic])
  end

  it 'marks fenced code with its language the way the post page highlighter expects' do
    out = doc("```ruby\nputs 1\n```")

    expect(out.at_css('pre > code.language-ruby').text).to eq("puts 1\n")
    expect(html("```ruby\nputs 1\n```")).not_to include('style=')
  end

  it 'adds no heading anchors' do
    expect(doc('# Hi').at_css('h1').inner_html).to eq('Hi')
  end

  it 'drops raw HTML instead of passing it through' do
    out = html("Hello\n\n<script>alert(1)</script>\n\n<img src=x onerror=alert(1)>")

    expect(out).not_to match(/<script|onerror|<img/)
  end

  it 'refuses javascript: links' do
    expect(html('[x](javascript:alert(1))')).not_to include('javascript:')
  end

  it 'returns an empty string for blank input' do
    expect([html(nil), html(''), html("  \n")]).to all(be_blank)
  end
end
