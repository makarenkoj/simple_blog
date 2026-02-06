class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :posts, through: :categorizations
  has_many :category_preferences, dependent: :destroy
  has_many :users, through: :category_preferences

  has_one_attached :cover_image

  before_validation :downcase_name

  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 50 }
  validates :cover_image, content_type: %w[image/png image/jpeg image/webp], size: { less_than: 5.megabytes }

  def to_param
    name.parameterize
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    ['posts']
  end

  private

  def downcase_name
    self.name = name.downcase
  end
end
