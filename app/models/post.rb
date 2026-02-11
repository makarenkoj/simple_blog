class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: %i[slugged history]

  belongs_to :user

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :bookmarks, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user

  has_rich_text :body

  has_one_attached :cover_image

  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :cover_image, content_type: %w[image/png image/gif image/jpeg image/webp],
                          size: { less_than_or_equal_to: 5.megabytes, message: I18n.t('attachments.cover_image.large') },
                          dimension: { width: { max: 2000 }, height: { max: 2000 }, message: I18n.t('attachments.cover_image.dimension') }

  validate :body_content_length

  after_create :notify_followers

  def self.ransackable_attributes(_auth_object = nil)
    %w[id title created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user categories rich_text_body]
  end

  def should_generate_new_friendly_id?
    title_changed?
  end

  def normalize_friendly_id(input)
    input.to_s.to_slug.transliterate(:ukrainian).normalize.to_s
  end

  private

  def notify_followers
    user.followers.find_each do |follower|
      Notification.create(user: follower,
                          actor: user,
                          notifiable: self,
                          action: 'new_post')
    end
  end

  def body_content_length
    plain_text = body&.to_plain_text&.strip

    if plain_text.blank?
      errors.add(:body, I18n.t('activerecord.errors.messages.post.title.blank'))
    elsif plain_text.length < 10
      errors.add(:body, I18n.t('activerecord.errors.messages.post.title.short'))
    end
  end
end
