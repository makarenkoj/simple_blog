class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }

  ACTIONS = {
    new_post: 'new_post',
    new_follower: 'new_follower'
  }.freeze

  validates :action, inclusion: { in: ACTIONS.values }

  def mark_as_read!
    Rails.logger.debug "\/nMarking notification #{id} as read\/n"
    update(read: true)
  end

  def message
    case action
    when 'new_post'
      I18n.t('notifications.new_post', author: actor.full_name, title: notifiable.title)
    when 'new_follower'
      I18n.t('notifications.new_follower', follower: actor.full_name)
    else
      I18n.t('notifications.default')
    end
  end

  after_create_commit do
    broadcast_replace_to(
      user,
      :notifications,
      target: 'notifications_dropdown',
      partial: 'partials/notifications_dropdown',
      locals: { user: user }
    )
  end
end
