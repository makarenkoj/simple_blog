class SearchService
  attr_reader :query, :limit, :scope

  def initialize(query:, limit: 20, scope: :all)
    @query = query.to_s.strip
    @limit = limit
    @scope = scope
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

    Post.where("title ILIKE :query OR
                body ILIKE :query OR
                EXISTS (SELECT 1 FROM action_text_rich_texts
                        WHERE record_type = 'Post'
                        AND record_id = posts.id
                        AND body ILIKE :query
                        )",
               query: "%#{sanitized_query}%").includes(:user, :categories, cover_image_attachment: :blob)
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
               query: "%#{sanitized_query}%").includes(avatar_attachment: :blob)
        .order(created_at: :desc)
        .limit(limit)
  end

  def search_categories
    return [] unless search_scope?(:categories)

    Category.where('name ILIKE :query',
                   query: "%#{sanitized_query}%").includes(cover_image_attachment: :blob)
            .order(name: :asc)
            .limit(limit)
  end

  def total_count
    @total_count ||= search_posts.count + search_users.count + search_categories.count
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
