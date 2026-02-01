class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: %i[click mark_as_read destroy]

  def index
    @notifications = current_user.notifications.recent.includes(:actor, :notifiable).page(params[:page]).per(20)

    # current_user.notifications.unread.update_all(read: true)
  end

  def click
    @notification.mark_as_read!

    target_path = case @notification.notifiable_type
                  when 'Post'
                    post_path(@notification.notifiable)
                  when 'User'
                    user_path(@notification.actor)
                  else
                    root_path
                  end

    redirect_to target_path
  end

  # TODO: maybe it does not need?
  def mark_as_read
    @notification.mark_as_read!

    redirect_to notifications_path, notice: t('notifications.marked_as_read')
  end

  def destroy
    @notification.destroy

    redirect_to notifications_path, notice: t('notifications.deleted')
  end

  private

  def set_notification
    @notification = current_user.notifications.find_by(id: params[:id])
    redirect_to notifications_path, alert: t('notifications.not_found') unless @notification
  end
end
