class CategoriesController < ApplicationController
  before_action :popular_categories
  before_action :popular_creators
  before_action :set_category, only: %i[show]

  def show
    @posts = @category.posts.includes(:user, :rich_text_body).order(created_at: :desc)
    render 'posts/index' 
  end

  def index
    @categories = Category.includes(:posts).order(:name)
  end

  private

  def set_category
    @category = Category.find_by(name: params[:id])
    redirect_back fallback_location: posts_path, alert: t('activerecord.controllers.categories.not_found') unless @category
  end
end
