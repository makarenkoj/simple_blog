require 'rails_helper'

# Admin areas (Avo, Mission Control) are granted by an explicit flag, never by
# an email address: emails are not verified, so whoever registers an address
# would otherwise inherit its rights.
RSpec.describe 'Admin access', type: :request do
  let(:admin) { create(:user, admin: true) }
  let(:impostor) { create(:user, email: 'admin@example.com', role: :creator) }

  around do |example|
    previous = ENV.fetch('AVO_EMAIL', nil)
    ENV['AVO_EMAIL'] = 'admin@example.com'
    example.run
  ensure
    ENV['AVO_EMAIL'] = previous
  end

  describe 'Avo' do
    it 'lets an admin in' do
      sign_in admin
      get '/avo/resources/users'

      expect(response).to have_http_status(:ok)
    end

    it 'turns away a non-admin even when they hold the configured admin email' do
      sign_in impostor
      get '/avo/resources/users'

      expect(response).to redirect_to('/')
    end

    it 'turns away a guest' do
      get '/avo/resources/users'

      expect(response).to redirect_to('/')
    end
  end

  describe 'Mission Control' do
    it 'lets an admin in' do
      sign_in admin
      get '/jobs'

      expect(response).to have_http_status(:ok)
    end

    it 'hides it from a non-admin creator holding the configured admin email' do
      sign_in impostor
      get '/jobs'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'sign-up' do
    it 'cannot grant admin through submitted params' do
      post user_registration_path, params: { user: { email: 'new@example.com', username: 'newbie',
                                                     first_name: 'New', last_name: 'User',
                                                     password: 'Password123!', password_confirmation: 'Password123!',
                                                     role: 'reader', admin: '1' } }

      expect(User.find_by(email: 'new@example.com')).to have_attributes(admin: false)
    end
  end
end
