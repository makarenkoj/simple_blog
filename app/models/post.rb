class Post < ApplicationRecord
  belongs_to :user

  has_rich_text :body

  has_one_attached :cover_image

  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :body, presence: true, length: { minimum: 10 }
  validates :cover_image, content_type: %w[image/png image/gif image/jpeg image/webp],
                          size: { less_than_or_equal_to: 5.megabytes, message: I18n.t('attachments.cover_image.large') },
                          dimension: { width: { max: 2000 }, height: { max: 2000 }, message: I18n.t('attachments.cover_image.dimension') }
end
