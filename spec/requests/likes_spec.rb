require 'rails_helper'

RSpec.describe 'Post likes', type: :request do
  include_context 'base'

  let(:author) { create(:user, role: :creator) }
  let(:published) { create(:post, user: author, status: :published) }

  def like(post, **opts) = post(post_like_path(post), **opts)
  def unlike(post) = delete(post_like_path(post))

  it 'sends a guest to sign in' do
    like(published)

    expect(response).to redirect_to(new_user_session_path)
    expect(Like.count).to eq(0)
  end

  context 'when signed in' do
    before { sign_in current_user }

    it "likes someone else's published post and notifies its author" do
      like(published)

      expect(current_user.likes.where(post: published).count).to eq(1)
      expect(author.notifications.where(action: 'post_liked', actor: current_user).count).to eq(1)
    end

    it 'renders the turbo stream update' do
      like(published, as: :turbo_stream)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream])
    end

    it 'counts a repeated like once and notifies once' do
      2.times { like(published) }

      expect(published.likes.count).to eq(1)
      expect(author.notifications.where(action: 'post_liked').count).to eq(1)
    end

    it 'does not let an author like their own post' do
      own = create(:post, user: current_user, status: :published)
      like(own)

      expect(own.likes.count).to eq(0)
    end

    it "cannot like or reveal another user's draft" do
      draft = create(:post, user: author, status: :draft)
      like(draft)

      expect(draft.likes.count).to eq(0)
      expect(author.notifications.count).to eq(0)
      expect(response).to redirect_to(posts_path)
    end

    it 'removes only the signed-in user like' do
      other_like = create(:user).likes.create!(post: published)
      current_user.likes.create!(post: published)

      unlike(published)

      expect(published.likes.reload).to contain_exactly(other_like)
    end
  end
end
