require 'rails_helper'

RSpec.describe 'Users', type: :request do
  include_context 'base'

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /users/:id (show)' do
    context 'when the user is not authorized' do
      it 'redirects to the login page' do
        get user_path(user)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when the user is authorized' do
      before { sign_in user }

      it 'successfully opens the profile page' do
        get user_path(user)

        expect(response).to have_http_status(:success)
      end

      it 'redirects to their own profile page when click old profile link' do
        get "/it/users/#{user.username}"

        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to(user_path(user))
      end
    end
  end

  describe 'GET /current_profile' do
    context 'when the user is not authorized' do
      it 'redirects to the login page' do
        get current_profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when the user is authorized' do
      before { sign_in user }

      it 'redirects to their own profile page' do
        get current_profile_path
        expect(response).to redirect_to(user_path(user))
      end
    end
  end

  describe 'DELETE /users/:id/delete_avatar' do
    before { sign_in user }

    context 'when the user deletes their own avatar' do
      it 'successfully deletes the avatar and redirects back' do
        delete delete_avatar_user_path(user), headers: { 'HTTP_REFERER' => user_path(user) }

        expect(response).to redirect_to(user_path(user))
        expect(flash[:notice]).to eq(I18n.t('flash.avatar_removed', default: 'Avatar was successfully removed.'))
      end
    end

    context "when the user tries to delete someone else's avatar" do
      it 'blocks the action and shows an error' do
        delete delete_avatar_user_path(other_user), headers: { 'HTTP_REFERER' => user_path(other_user) }

        expect(response).to redirect_to(user_path(other_user))
        expect(flash[:alert]).to eq(I18n.t('flash.not_authorized', default: 'You are not authorized to perform this action.'))
      end
    end
  end

  describe 'POST /update_fcm_token' do
    let(:valid_token) { 'new_fcm_token_123' }
    let(:post_request) { post update_fcm_token_path, params: { token: valid_token } }

    context 'when the user is not authorized (or WebView session is lost)' do
      it 'returns error 401 Unauthorized' do
        post_request

        expect(response).to have_http_status(:unauthorized)
        expect(data['error']).to eq('Not logged in')
      end
    end

    context 'when the user is authorized' do
      before { sign_in user }

      it 'successfully saves the token and returns status 200 OK' do
        post_request

        expect(response).to have_http_status(:ok)
        expect(data['status']).to eq('ok')
        expect(user.reload.fcm_token).to eq(valid_token)
      end

      it 'removes this token from another user (if it belonged to them)' do
        other_user.update(fcm_token: valid_token)

        post_request

        expect(user.reload.fcm_token).to eq(valid_token)
        expect(other_user.reload.fcm_token).to be_nil
      end

      it 'does not make unnecessary requests if the token has not changed' do
        user.update(fcm_token: valid_token)

        expect(User).not_to receive(:transaction)

        post_request

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
