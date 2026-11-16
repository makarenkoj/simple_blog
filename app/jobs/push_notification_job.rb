class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification)
    FcmService.send_notification(notification)
  end
end
