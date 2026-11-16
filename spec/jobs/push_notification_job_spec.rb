require 'rails_helper'

RSpec.describe PushNotificationJob, type: :job do
  it 'sends the notification through FCM' do
    notification = create(:notification)
    expect(FcmService).to receive(:send_notification).with(notification)

    described_class.perform_now(notification)
  end
end
