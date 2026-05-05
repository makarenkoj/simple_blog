class PostsController < ApplicationController
  before_action :authenticate_user!, except: %i[show index]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]
  before_action :popular_categories, only: %i[index show library]
  before_action :popular_creators, only: %i[index show library]

  def index
    @posts_scope = Post.published.includes(:user, :categories).with_attached_cover_image.order(created_at: :desc)

    @posts_scope = @posts_scope.joins(:categories).where(categories: { id: params[:category_ids] }) if params[:category_ids].present?

    @pagy, @posts = pagy(@posts_scope, limit: 5)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    set_meta_tags title: @post.title,
                  description: @post.body.to_plain_text.truncate(160),
                  keywords: @post.categories.map(&:name).join(', '),
                  canonical: request.original_url,
                  og: {
                    title: @post.title,
                    type: 'article',
                    image: @post.cover_image.attached? ? url_for(@post.cover_image) : nil
                  }

    @more_from_author = if @post.user
                          @post.user.posts.published.where.not(id: @post.id).order('RANDOM()').limit(3)
                        else
                          []
                        end
  end

  def new
    @post = current_user.posts.build
  end

  def edit; end

  def create
    @post = Post.create(post_params.merge(user: current_user))
    if @post.save
      redirect_to @post, notice: I18n.t('activerecord.controllers.posts.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      respond_to do |format|
        format.html { redirect_to @post, notice: I18n.t('activerecord.controllers.posts.updated') }

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @post,
            partial: 'posts/post',
            locals: { post: @post }
          )
        end
      end
    else
      render :edit
    end
  end

  def library
    scope = current_user.bookmarked_posts.published.includes(:user, :rich_text_body).order('bookmarks.created_at DESC')
    @pagy, @posts = pagy(scope, limit: 5)

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream { render :index }
    end
  end

  def destroy
    @post.destroy
    redirect_to user_path(current_user, format: :html), notice: I18n.t('activerecord.controllers.posts.destroyed'), status: :see_other
  end

  private

  def authorize_owner!
    return if current_user_can_edit?(@post)

    redirect_to posts_path, alert: t('activerecord.controllers.posts.not_your_post')
  end

  def set_post
    @post = Post.friendly.find(params[:id])

    return unless @post && !@post.published? && !current_user_can_edit?(@post)

    redirect_to posts_path, alert: t('activerecord.controllers.posts.not_your_post')
  end

  def post_params
    params.require(:post).permit(:title, :body, :status, :cover_image, category_ids: [])
  end
end
