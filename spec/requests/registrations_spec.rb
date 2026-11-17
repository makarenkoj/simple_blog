require 'rails_helper'

RSpec.describe 'User registrations', type: :request do
  include_context 'base'

  # Only the owner makes someone a creator (in Avo); a client-submitted role is ignored.
  describe 'role cannot be chosen by the user' do
    it 'registers a reader even when role=creator is submitted' do
      post user_registration_path, params: { user: { email: 'new@example.com', username: 'newbie',
                                                     first_name: 'New', last_name: 'User',
                                                     password: 'Password123!', password_confirmation: 'Password123!',
                                                     role: 'creator' } }

      expect(User.find_by(email: 'new@example.com')).to be_reader
    end

    it 'keeps a reader a reader when a profile update submits role=creator' do
      sign_in current_user
      put user_registration_path, params: { user: { first_name: 'Petro', role: 'creator' } }

      expect(current_user.reload).to have_attributes(first_name: 'Petro', role: 'reader')
    end
  end

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
