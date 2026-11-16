require 'rails_helper'

RSpec.describe 'User registrations', type: :request do
  include_context 'base'

  describe 'PUT /users (profile update)' do
    before { sign_in current_user }

    # Sentry: "No previewer found and can't transform blob ... image/svg+xml".
    it 'rejects an SVG avatar and re-renders the form instead of crashing' do
      put user_registration_path, params: { user: { avatar: fixture_file_upload('image.svg', 'image/svg+xml'),
                                                    current_password: 'Password123!' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(current_user.reload.avatar).not_to be_attached
    end
  end
end
