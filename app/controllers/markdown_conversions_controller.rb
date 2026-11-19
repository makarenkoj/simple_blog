# Converts Markdown sent by the editor's ".md import" into HTML for Tiptap, with the same
# converter the API uses for body_markdown (SAM1-29). Nothing is stored here; the result
# becomes part of the post only when the author saves it.
class MarkdownConversionsController < ApplicationController
  MAX_BYTES = 500.kilobytes

  before_action :authenticate_user!

  def create
    markdown = params[:markdown].to_s
    return head(:content_too_large) if markdown.bytesize > MAX_BYTES

    render json: { html: MarkdownToHtml.call(markdown) }
  end
end
