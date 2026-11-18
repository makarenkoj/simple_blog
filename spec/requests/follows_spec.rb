require 'rails_helper'

RSpec.describe 'Follows', type: :request do
  include_context 'base'

  let(:creator) { create(:user, role: :creator) }

  it 'sends a guest to sign in' do
    post follow_user_path(creator)

    expect(response).to redirect_to(new_user_session_path)
    expect(Follow.count).to eq(0)
  end

  context 'when signed in' do
    before { sign_in current_user }

    it 'follows a creator and notifies them' do
      post follow_user_path(creator)

      expect(current_user.reload.followings).to contain_exactly(creator)
      expect(creator.notifications.where(action: 'new_follower', actor: current_user).count).to eq(1)
      expect(response).to redirect_to(user_path(creator))
    end

    it 'renders the turbo stream update' do
      post follow_user_path(creator), as: :turbo_stream

      expect(response.media_type).to eq(Mime[:turbo_stream])
    end

    it 'does not follow twice or notify twice' do
      2.times { post follow_user_path(creator) }

      expect(Follow.where(follower: current_user, following: creator).count).to eq(1)
      expect(creator.notifications.where(action: 'new_follower').count).to eq(1)
    end

    it 'refuses to follow a reader' do
      reader = create(:user, role: :reader)
      post follow_user_path(reader)

      expect(Follow.count).to eq(0)
      expect(flash[:alert]).to be_present
    end

    it 'refuses to follow oneself' do
      current_user.update!(role: :creator)
      post follow_user_path(current_user)

      expect(Follow.count).to eq(0)
    end

    it "unfollows, leaving other users' follows alone" do
      others = Follow.create!(follower: create(:user), following: creator)
      Follow.create!(follower: current_user, following: creator)

      delete unfollow_user_path(creator)

      expect(Follow.all).to contain_exactly(others)
    end
  end
end
