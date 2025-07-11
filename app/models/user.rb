class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy

  has_one_attached :avatar

  enum :role, { reader: 0, creator: 1 }

  validates :first_name, length: { maximum: 50 }
  validates :last_name, length: { maximum: 50 }
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 20 }
  validates :role, presence: true

  validates :username, format: { with: /^[a-zA-Z0-9_.]*$/, multiline: true }
  validates :avatar, content_type: %w[image/png image/gif image/jpeg image/webp],
                     size: { less_than_or_equal_to: 2.megabytes, message: I18n.t('attachments.avatar.large') } # ,
  #  dimension: { width: { max: 500 }, height: { max: 500 }, message: t('attachments.avatar.dimension') }

  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def creator?
    role == 'creator'
  end
end
