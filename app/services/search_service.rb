class SearchService
  attr_reader :query, :limit, :scope, :current_user

  def initialize(query:, limit: 20, scope: :all, current_user: nil)
    @query = query.to_s.strip
    @limit = limit
    @scope = scope
    @current_user = current_user
  end

  def call
    return empty_results if query.blank? || query.length < 2

    { posts: search_posts,
      users: search_users,
      categories: search_categories,
      total_count: total_count }
  end

  private

  def search_posts
    return [] unless search_scope?(:posts)

    visible_posts.where('posts.title ILIKE :query OR posts.body_html ILIKE :query', query: "%#{sanitized_query}%")
                 .includes(:categories, user: { avatar_attachment: :blob }, cover_image_attachment: :blob)
                 .order(created_at: :desc)
                 .limit(limit)
  end

  def search_users
    return [] unless search_scope?(:users)

    User.where("username ILIKE :query OR
                first_name ILIKE :query OR
                last_name ILIKE :query OR
                email ILIKE :query OR
                CONCAT(first_name, ' ', last_name) ILIKE :query",
               query: "%#{sanitized_query}%")
        .includes(avatar_attachment: :blob)
        .order(created_at: :desc)
        .limit(limit)
  end

  def search_categories
    return [] unless search_scope?(:categories)

    Category.where('name ILIKE :query', query: "%#{sanitized_query}%")
            .includes(cover_image_attachment: :blob)
            .order(name: :asc)
            .limit(limit)
  end

  def visible_posts
    if current_user.present?
      Post.where(status: :published).or(Post.where(status: :draft, user_id: current_user.id))
    else
      Post.where(status: :published)
    end
  end

  def total_count
    @total_count ||= search_posts.size + search_users.size + search_categories.size
  end

  def sanitized_query
    @sanitized_query ||= ActiveRecord::Base.sanitize_sql_like(query)
  end

  def search_scope?(resource)
    [:all, resource].include?(scope)
  end

  def empty_results
    { posts: [],
      users: [],
      categories: [],
      total_count: 0 }
  end
end
