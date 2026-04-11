module Api
  module V1
    class PostsController < BaseController
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
          body: post.body.to_s,
          category_ids: post.category_ids,
          cover_url: cover_image_url(post),
          created_at: post.created_at
        }
      end

      def cover_image_url(post)
        return nil unless post.cover_image.attached?

        url_for(post.cover_image)
      end

      def post_params
        params.require(:post).permit(:title, :body, :status, :cover_image, category_ids: [])
      end
    end
  end
end
