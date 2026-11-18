require 'rails_helper'

RSpec.describe 'Notifications', type: :request do
  include_context 'base'

  let(:author) { create(:user, role: :creator) }
  let(:post_record) { create(:post, user: author, status: :published) }
  let!(:mine) { create(:notification, user: current_user, notifiable: post_record, action: 'post_liked') }
  let!(:theirs) { create(:notification, user: author) }

  it 'sends a guest to sign in' do
    get notifications_path

    expect(response).to redirect_to(new_user_session_path)
  end

  context 'when signed in' do
    before { sign_in current_user }

    it 'lists only the signed-in user notifications' do
      get notifications_path

      expect(response).to have_http_status(:ok)
      expect(controller.instance_variable_get(:@notifications)).to contain_exactly(mine)
    end

    it 'marks a notification read on click and opens its post' do
      get click_notification_path(mine)

      expect(mine.reload).to be_read
      expect(response).to redirect_to(post_path(post_record))
    end

    it 'marks a notification read' do
      patch mark_as_read_notification_path(mine)

      expect(mine.reload).to be_read
    end

    it 'deletes own notification' do
      delete notification_path(mine)

      expect(Notification.exists?(mine.id)).to be(false)
    end

    it "cannot read, mark or delete another user's notification" do
      get click_notification_path(theirs)
      patch mark_as_read_notification_path(theirs)
      delete notification_path(theirs)

      expect(theirs.reload).to have_attributes(read: false)
      expect(response).to redirect_to(notifications_path)
    end
  end
end
