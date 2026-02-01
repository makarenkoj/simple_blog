class PostsController < ApplicationController
  before_action :authenticate_user!, except: %i[show index]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]
  before_action :popular_categories, only: %i[index show]
  before_action :popular_creators, only: %i[index show]

  def index
    @posts = Post.all
  end

  def show; end

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
      redirect_to @post, notice: I18n.t('activerecord.controllers.posts.updated')
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: I18n.t('activerecord.controllers.posts.destroyed')
  end

  private

  def popular_categories
    scope = Category.left_joins(:posts)

    if user_signed_in?
      scope = scope.where.not(id: current_user.category_preferences.select(:category_id))
    end

    @categories = scope.group('categories.id')
                        .order('COUNT(posts.id) DESC')
                        .limit(5)
  end

  def popular_creators
    scope = User.creator.left_joins(:followers)

    if user_signed_in?
      scope = scope.where.not(id: current_user.followings.select(:id)).where.not(id: current_user.id)
    end

    @creators = scope.group('users.id')
                     .order('COUNT(follows.id) DESC')
                     .limit(5)
  end

  def authorize_owner!
    return if current_user_can_edit?(@post)

    redirect_to posts_path, alert: t('activerecord.controllers.posts.not_your_post')
  end

  def set_post
    @post = Post.find_by(id: params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :cover_image, category_ids: [])
  end
end
