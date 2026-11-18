require 'rails_helper'
require 'turbo/broadcastable/test_helper'

# The layout subscribes each signed-in user to turbo_stream_from(user, :notifications);
# a new notification must reach that stream with the badge and dropdown updates.
RSpec.describe Notification, type: :model do
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  let(:recipient) { create(:user, role: :creator) }
  let(:post_record) { create(:post, user: recipient, status: :published) }

  it "updates the recipient's open pages through their notifications stream" do
    perform_enqueued_jobs(only: Turbo::Streams::ActionBroadcastJob) do
      create(:notification, user: recipient, notifiable: post_record, action: 'post_liked')
    end

    targets = capture_turbo_stream_broadcasts([recipient, :notifications]).map { |stream| stream['target'] }
    expect(targets).to contain_exactly('notifications_dropdown', 'profile_notifications_button',
                                       'mobile_header_notifications_wrapper')
  end

  it "does not touch anyone else's stream" do
    bystander = create(:user)

    perform_enqueued_jobs(only: Turbo::Streams::ActionBroadcastJob) do
      create(:notification, user: recipient, notifiable: post_record, action: 'post_liked')
    end

    expect(capture_turbo_stream_broadcasts([bystander, :notifications])).to be_empty
  end
end
