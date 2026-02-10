class User < ApplicationRecord
  extend FriendlyId
  friendly_id :username, use: %i[slugged history]

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :category_preferences, dependent: :destroy
  has_many :preferred_categories, through: :category_preferences, source: :category
  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy, inverse_of: :follower
  has_many :followings, through: :following_relationships, source: :following
  has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow', dependent: :destroy, inverse_of: :following
  has_many :followers, through: :follower_relationships, source: :follower
  has_many :notifications, dependent: :destroy
  has_many :initiated_notifications, foreign_key: :actor_id, class_name: 'Notification', dependent: :destroy, inverse_of: :actor
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_posts, through: :bookmarks, source: :post
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  has_one_attached :avatar

  enum :role, { reader: 0, creator: 1 }

  validates :first_name, length: { maximum: 50 }
  validates :last_name, length: { maximum: 50 }
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 20 }
  validates :role, presence: true

  validates :username, format: { with: /\A[a-zA-Z0-9_.]*\z/ }
  validates :avatar, content_type: %w[image/png image/gif image/jpeg image/webp],
                     size: { less_than_or_equal_to: 2.megabytes, message: I18n.t('attachments.avatar.large') } # ,
  #  dimension: { width: { max: 500 }, height: { max: 500 }, message: t('attachments.avatar.dimension') }

  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def creator?
    role == 'creator'
  end

  def follow(user)
    return false if user == self || following?(user) || !user.creator?

    following_relationships.create(following: user)

    user.notifications.create(
      actor: self,
      notifiable: user,
      action: 'new_follower'
    )
  end

  def unfollow(user)
    following_relationships.find_by(following: user)&.destroy
  end

  def following?(user)
    followings.include?(user)
  end

  def followed_by?(user)
    followers.include?(user)
  end

  def unread_notifications_count
    notifications.unread.count
  end

  def bookmarked?(post)
    bookmarks.exists?(post: post)
  end

  def liked?(post)
    liked_posts.exists?(post.id)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id username email first_name last_name role created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[posts followers followings preferred_categories]
  end

  def should_generate_new_friendly_id?
    username_changed? || super
  end

  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize(transliterations: :ukrainian).to_s
  end
end
