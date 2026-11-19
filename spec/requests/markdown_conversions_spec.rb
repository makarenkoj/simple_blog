require 'rails_helper'

# The editor's ".md import" sends the file's text here and inserts the returned HTML into
# Tiptap. Same converter as the API's body_markdown (SAM1-29).
RSpec.describe 'Markdown conversion', type: :request do
  include_context 'base'

  def convert(markdown, **headers)
    post markdown_conversion_path, params: { markdown: markdown }, as: :json, headers: headers
    response
  end

  it 'is only for signed-in users' do
    expect(convert('# Hi')).to have_http_status(:unauthorized)
  end

  context 'when signed in' do
    before { sign_in current_user }

    it 'returns the HTML for the Markdown' do
      expect(convert("## Title\n\n```ruby\nputs 1\n```")).to have_http_status(:ok)

      html = response.parsed_body['html']
      expect(html).to include('<h2>Title</h2>', '<code class="language-ruby">')
    end

    it 'drops raw HTML from the Markdown' do
      convert("Hi\n\n<script>alert(1)</script>")

      expect(response.parsed_body['html']).not_to include('<script')
    end

    it 'refuses a document larger than the limit' do
      expect(convert('a' * (MarkdownConversionsController::MAX_BYTES + 1))).to have_http_status(:content_too_large)
    end
  end
end
