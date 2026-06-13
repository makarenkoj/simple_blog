class PostsController < ApplicationController
  before_action :authenticate_user!, except: %i[show index]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]
  before_action :popular_categories, only: %i[index show library]
  before_action :popular_creators, only: %i[index show library]
  before_action :set_filter_categories, only: %i[index library]

  def index
    @posts_scope = Post.published.includes(:categories, user: { avatar_attachment: :blob }, cover_image_attachment: :blob).order(created_at: :desc)
    @posts_scope = @posts_scope.joins(:categories).where(categories: { id: params[:category_ids] }).distinct if params[:category_ids].present?
    @pagy, @posts = pagy(@posts_scope, limit: 5)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    prepare_meta_tags
    PostViewTracker.new(@post, request, current_user).track
    @more_from_author = fetch_more_from_author
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
          render turbo_stream: turbo_stream.replace(@post, partial: 'posts/post', locals: { post: @post })
        end
      end
    else
      render :edit
    end
  end

  def library
    scope = current_user.bookmarked_posts.published.includes(:categories, user: { avatar_attachment: :blob }, cover_image_attachment: :blob).order('bookmarks.created_at DESC')
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
    @post = Post.friendly.includes(:categories, user: { avatar_attachment: :blob }, cover_image_attachment: :blob).find(params[:id])

    return unless @post && !@post.published? && !current_user_can_edit?(@post)

    redirect_to posts_path, alert: t('activerecord.controllers.posts.not_your_post')
  end

  def post_params
    params.require(:post).permit(:title, :body_html, :status, :cover_image, category_ids: [])
  end

  def prepare_meta_tags
    cover_url = @post.cover_image.attached? ? url_for(@post.cover_image) : nil
    plain_description = view_context.strip_tags(@post.body_html.to_s).truncate(160)

    set_meta_tags title: @post.title,
                  description: plain_description,
                  keywords: @post.categories.map(&:name).join(', '),
                  canonical: request.original_url,
                  author: @post.user&.username,
                  og: { title: @post.title, description: plain_description, type: 'article', url: request.original_url, image: cover_url },
                  twitter: { card: 'summary_large_image', title: @post.title, description: plain_description, image: cover_url }
  end

  def fetch_more_from_author
    return [] unless @post.user

    @post.user.posts.published.where.not(id: @post.id).with_attached_cover_image.order('RANDOM()').limit(3)
  end

  def set_filter_categories
    @filter_categories = Category.with_posts_count.order(:name)
  end
end
