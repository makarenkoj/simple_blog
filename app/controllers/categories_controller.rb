class CategoriesController < ApplicationController
  before_action :popular_categories
  before_action :popular_creators
  before_action :set_category, only: %i[show]

  def show
    query = @category.posts.includes(:user, :rich_text_body)
    query = query.joins(:categories).where(categories: { id: params[:category_ids] }).distinct if params[:category_ids].present?
    @pagy, @posts = pagy(query.order(created_at: :desc), limit: 5)
    post_ids = @category.posts.select(:id)
    @category_counts = Category.joins(:posts).where(posts: { id: post_ids }).where.not(id: @category.id).group('categories.id').count
    @filter_categories = Category.where(id: @category_counts.keys).order(:name)

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
