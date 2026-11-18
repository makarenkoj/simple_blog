require 'rails_helper'

RSpec.describe 'Post bookmarks', type: :request do
  include_context 'base'

  let(:author) { create(:user, role: :creator) }
  let(:published) { create(:post, user: author, status: :published) }

  it 'sends a guest to sign in' do
    post post_bookmark_path(published)

    expect(response).to redirect_to(new_user_session_path)
    expect(Bookmark.count).to eq(0)
  end

  context 'when signed in' do
    before { sign_in current_user }

    it 'bookmarks a published post once, however often it is requested' do
      2.times { post post_bookmark_path(published) }

      expect(current_user.bookmarks.where(post: published).count).to eq(1)
    end

    it 'renders the turbo stream update' do
      post post_bookmark_path(published), as: :turbo_stream

      expect(response.media_type).to eq(Mime[:turbo_stream])
    end

    it "cannot bookmark another user's draft" do
      draft = create(:post, user: author, status: :draft)
      post post_bookmark_path(draft)

      expect(Bookmark.count).to eq(0)
      expect(response).to redirect_to(posts_path)
    end

    it 'removes only the signed-in user bookmark, and drops the card in the library' do
      others = create(:bookmark, post: published)
      create(:bookmark, user: current_user, post: published)

      delete post_bookmark_path(published, source: 'library'), as: :turbo_stream

      expect(Bookmark.all).to contain_exactly(others)
      expect(response.body).to include('action="remove"')
    end

    it 'redirects with an alert for an unknown post' do
      post post_bookmark_path('no-such-post')

      expect(response).to redirect_to(posts_path)
      expect(flash[:alert]).to be_present
    end
  end
end
