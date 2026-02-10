module Posts
  class LikesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_post

    def create
      return redirect_back fallback_location: posts_path, alert: t('activerecord.attributes.likes.errors.user_is_not_post_author') if @post.user_id == current_user.id

      if current_user.likes.create(post: @post)
        Notification.create(user: @post.user, actor: current_user, notifiable: @post.user, action: 'post_liked') # TODO: moove to service and logic
        flash.now[:notice] = t('activerecord.attributes.posts.liked_flash')
      end

      respond_to do |format|
        format.html { redirect_back fallback_location: posts_path }
        format.turbo_stream
      end
    end

    def destroy
      like = current_user.likes.find_by(post: @post)
      like&.destroy

      respond_to do |format|
        format.html { redirect_back fallback_location: posts_path }
        format.turbo_stream
      end
    end

    private

    def set_post
      @post = Post.friendly.find(params[:post_id])
    end
  end
end
