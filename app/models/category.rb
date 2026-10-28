class Category < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: %i[slugged history]

  has_many :categorizations, dependent: :destroy
  has_many :posts, through: :categorizations
  has_many :category_preferences, dependent: :destroy
  has_many :users, through: :category_preferences

  has_one_attached :cover_image

  before_validation :downcase_name

  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 50 }
  validates :cover_image, content_type: %w[image/png image/jpeg image/webp], size: { less_than: 5.megabytes }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    ['posts']
  end

  scope :with_posts_count, lambda {
    left_joins(:posts).where('posts.id IS NULL OR posts.status = ?', Post.statuses[:published]).group('categories.id').select('categories.*, COUNT(posts.id) AS posts_count')
  }

  def should_generate_new_friendly_id?
    name_changed? || slug.blank?
  end

  def normalize_friendly_id(input)
    input.to_s.to_slug.transliterate(:ukrainian).normalize.to_s
  end

  private

  def downcase_name
    self.name = name.downcase
  end
end
