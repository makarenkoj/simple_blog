class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validate :user_is_not_post_author

  private

  def user_is_not_post_author
    return unless post.user_id == user_id

    errors.add(:user, I18n.t('activerecord.attributes.likes.errors.user_is_not_post_author'))
  end
end
