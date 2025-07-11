class PostsController < ApplicationController
  before_action :authenticate_user!, except: %i[show index]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :set_current_user_post, only: %i[edit update destroy]

  def index
    @posts = Post.all
  end

  def show
  end

  def new
    @post = current_user.posts.build
  end

  def edit
  end

  def create
    @post = Post.create(post_params.merge(user: current_user))
    if @post.save
      redirect_to @post, notice: I18n.t('activerecord.controllers.posts.created')
    else
      render :new
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

  def set_current_user_post
    @post = current_user.posts.find(params[:id])
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :cover_image)
  end
end
