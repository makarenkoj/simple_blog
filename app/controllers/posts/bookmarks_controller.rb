module Posts
  class BookmarksController < ApplicationController
    before_action :authenticate_user!
    before_action :set_post

    def create
      current_user.bookmarks.create(post: @post)

      respond_to do |format|
        format.html { redirect_to posts_path }
        format.turbo_stream
      end
    end

    def destroy
      bookmark = current_user.bookmarks.find_by(post: @post)
      bookmark&.destroy

      respond_to do |format|
        format.html { redirect_to posts_path }
        format.turbo_stream do
          if params[:source] == 'library'
            render turbo_stream: turbo_stream.remove(@post)
          else
            render turbo_stream: turbo_stream.replace("bookmark_button_#{@post.id}", partial: "posts/bookmarks/button", locals: { post: @post, source: nil })
          end
        end
      end
    end

    private

    def set_post
      @post = Post.find_by(id: params[:post_id])

      unless @post
        redirect_to posts_path, alert: t('activerecord.controllers.posts.not_found')
      end
    end
  end
end
