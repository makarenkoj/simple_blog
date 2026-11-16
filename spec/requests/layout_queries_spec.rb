require 'rails_helper'

RSpec.describe 'Layout queries', type: :request do
  include_context 'base'

  # The bell, the mobile header and the profile button each showed the unread count,
  # several times per partial — one COUNT each, on every page a member opens.
  it 'counts unread notifications once per page' do
    create(:notification, user: current_user)
    sign_in current_user

    sql = []
    callback = ->(*, payload) { sql << payload[:sql] }
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') { get posts_path }

    expect(response).to have_http_status(:success)
    expect(sql.grep(/COUNT\(\*\) FROM "notifications"/).size).to eq(1)
  end
end
