module Api
  module V1
    class PostsController < BaseController
      include UploadedFilesOnly

      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          render json: { message: I18n.t('activerecord.controllers.posts.created'), post: post_response(@post) }, status: :created
        else
          render json: { message: I18n.t('errors.messages.not_saved', count: @post.errors.count, resource: 'Post'),
                         errors: @post.errors.to_hash,
                         full_messages: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def post_response(post)
        {
          id: post.id,
          slug: post.slug,
          title: post.title,
          status: post.status,
          body_html: post.body_html.to_s,
          category_ids: post.category_ids,
          cover_url: cover_image_url(post),
          created_at: post.created_at
        }
      end

      def cover_image_url(post)
        return nil unless post.cover_image.attached?

        url_for(post.cover_image)
      end

      # body_markdown is an alternative input: it is converted to HTML only when body_html is
      # blank, so a client that sends both gets exactly its HTML (SAM1-29).
      def post_params
        attributes = uploaded_files_only(
          params.require(:post).permit(:title, :body_html, :status, :cover_image, category_ids: []), :cover_image
        )
        markdown = params.dig(:post, :body_markdown)
        attributes[:body_html] = MarkdownToHtml.call(markdown) if attributes[:body_html].blank? && markdown.present?
        attributes
      end
    end
  end
end
