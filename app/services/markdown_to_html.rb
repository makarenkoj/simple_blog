# Markdown is an input format only: it is converted once, stored as posts.body_html like
# editor HTML, and rendered through PostBodySanitizer (SAM1-29). One converter serves the
# API (body_markdown) and the editor's .md import.
class MarkdownToHtml
  OPTIONS = {
    # unsafe: false drops raw HTML and dangerous link schemes (javascript:, data:).
    # github_pre_lang: false writes <pre><code class="language-ruby">, the form the post
    # page's highlight.js reads.
    render: { unsafe: false, github_pre_lang: false },
    extension: { table: true, strikethrough: true, autolink: true, tasklist: true, header_ids: nil }
  }.freeze
  # The post page highlights code itself; commonmarker's highlighter would add inline styles.
  PLUGINS = { syntax_highlighter: nil }.freeze

  def self.call(markdown)
    return '' if markdown.blank?

    Commonmarker.to_html(markdown.to_s, options: OPTIONS, plugins: PLUGINS)
  end
end
