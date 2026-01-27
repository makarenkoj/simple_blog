class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :posts, through: :categorizations
  has_many :category_preferences, dependent: :destroy
  has_many :users, through: :category_preferences

  validates :name, presence: true, uniqueness: true
end
