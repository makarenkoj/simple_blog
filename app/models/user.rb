class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy

  enum :role, { reader: 0, creator: 1 }

  validates :first_name, length: { maximum: 50 }
  validates :last_name, length: { maximum: 50 }
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 20 } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :role, presence: true

  validates :username, format: { with: /^[a-zA-Z0-9_.]*$/, multiline: true }

  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def self.creator?
    slef.role == 'creator'
  end
end
