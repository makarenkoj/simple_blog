class CategoriesController < ApplicationController
  before_action :popular_categories
  before_action :popular_creators
  before_action :set_category, only: %i[show]

  def show
    query = @category.posts.published.includes(:user, :rich_text_body, :categories).with_attached_cover_image
    query = query.joins(:categories).where(categories: { id: params[:category_ids] }).distinct if params[:category_ids].present?
    @pagy, @posts = pagy(query.order(created_at: :desc), limit: 5)

    set_filter_categories

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

  def set_filter_categories
    @filter_categories = Category.joins(:posts)
                                 .where(posts: { id: @category.posts.select(:id) })
                                 .where.not(id: @category.id)
                                 .group('categories.id')
                                 .select('categories.*, COUNT(posts.id) AS posts_count')
                                 .order(:name)
  end
end
