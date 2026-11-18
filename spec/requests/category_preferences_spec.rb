require 'rails_helper'

RSpec.describe 'Category preferences', type: :request do
  include_context 'base'

  let(:category) { create(:category) }

  it 'sends a guest to sign in' do
    post category_preference_path(category)

    expect(response).to redirect_to(new_user_session_path)
  end

  context 'when signed in' do
    before { sign_in current_user }

    it 'subscribes once, however often it is requested' do
      2.times { post category_preference_path(category), as: :turbo_stream }

      expect(current_user.preferred_categories.reload).to contain_exactly(category)
      expect(response.media_type).to eq(Mime[:turbo_stream])
    end

    it 'unsubscribes' do
      current_user.preferred_categories << category
      delete category_preference_path(category)

      expect(current_user.preferred_categories.reload).to be_empty
    end

    it 'answers 404 for an unknown category' do
      post category_preference_path('no-such-category'), as: :turbo_stream

      expect(response).to have_http_status(:not_found)
    end
  end
end
