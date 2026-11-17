require 'rails_helper'

RSpec.describe NotifyFollowersJob, type: :job do
  let(:creator) { create(:user, :creator) }
  let(:post) { create(:post, user: creator) }

  before { create_list(:user, 3, :reader).each { |follower| Follow.create!(follower: follower, following: creator) } }

  it 'gives every follower a new_post notification' do
    expect { described_class.perform_now(post) }.to change(Notification, :count).by(3)
    expect(Notification.where(actor: creator, notifiable: post, action: 'new_post').pluck(:user_id))
      .to match_array(creator.followers.ids)
  end

  it 'does nothing for an author without followers' do
    lonely_post = create(:post, user: create(:user, :creator))

    expect { described_class.perform_now(lonely_post) }.not_to change(Notification, :count)
  end

  it 'leaves push and live updates to background jobs instead of rendering inline' do
    expect { described_class.perform_now(post) }
      .to have_enqueued_job(PushNotificationJob).exactly(3).times
      .and have_enqueued_job(Turbo::Streams::ActionBroadcastJob).at_least(3).times
  end
end
