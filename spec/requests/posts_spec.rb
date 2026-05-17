require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  include_context 'base'

  let(:other_user) { create(:user) }
  let!(:published_post) { create(:post, user: current_user, status: :published, title: 'Published News') }
  let!(:draft_post) { create(:post, user: current_user, status: :draft, title: 'Secret Draft') }

  describe 'GET /posts (Index)' do
    it 'returns http success and shows only published posts' do
      get posts_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(published_post.title)
      expect(response.body).not_to include(draft_post.title)
    end
  end

  describe 'GET /posts/:id (Show)' do
    context 'when the post is PUBLISHED' do
      it 'allows a guest (unauthenticated user) to see the post' do
        get post_path(published_post)

        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_post.title)
      end

      it 'calls the PostViewTracker service' do
        mock_tracker = instance_double(PostViewTracker)

        allow(PostViewTracker).to receive(:new).and_return(mock_tracker)
        expect(mock_tracker).to receive(:track)

        get post_path(published_post)

        expect(response).to be_successful
      end
    end

    context 'when the post is a DRAFT' do
      it 'redirects a guest to the index page with an alert' do
        get post_path(draft_post)

        expect(response).to redirect_to(posts_path)
        expect(flash[:alert]).to eq(I18n.t('activerecord.controllers.posts.not_your_post'))
      end

      it 'redirects another authenticated user to the index page' do
        sign_in other_user
        get post_path(draft_post)

        expect(response).to redirect_to(posts_path)
        expect(flash[:alert]).to eq(I18n.t('activerecord.controllers.posts.not_your_post'))
      end

      it 'allows the AUTHOR to see their own draft' do
        sign_in current_user
        get post_path(draft_post)

        expect(response).to have_http_status(:success)
        expect(response.body).to include(draft_post.title)
      end
    end

    context 'when visiting a URL with an old locale prefix' do
      it 'redirects permanently (301) to the clean post path without locale uk' do
        get "/uk/posts/#{published_post.slug}"

        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to(post_path(published_post))
      end

      it 'redirects permanently (301) to the clean post path without locale en' do
        get "/en/posts/#{published_post.slug}"

        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to(post_path(published_post))
      end
    end
  end

  describe 'GET /posts/new' do
    it 'redirects guests to login' do
      get new_post_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it 'allows authenticated users to access the form' do
      sign_in current_user
      get new_post_path

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /posts (Create)' do
    it 'creates a new post for the logged-in user' do
      valid_params = { post: { title: 'New Post', body: 'Content' * 100, status: 'draft' } }

      sign_in current_user

      expect { post posts_path, params: valid_params }.to change(Post, :count).by(1)
      expect(Post.last.user).to eq(current_user)
      expect(response).to redirect_to(post_path(Post.last))
      expect(flash[:notice]).to eq(I18n.t('activerecord.controllers.posts.created'))
    end
  end

  describe 'GET /posts/:id/edit' do
    it 'allows the author to edit' do
      sign_in current_user
      get edit_post_path(published_post)

      expect(response).to have_http_status(:success)
    end

    it 'prevents other users from editing' do
      sign_in other_user
      get edit_post_path(published_post)

      expect(response).to redirect_to(posts_path)
      expect(flash[:alert]).to eq(I18n.t('activerecord.controllers.posts.not_your_post'))
    end
  end

  describe 'PATCH /posts/:id (Update)' do
    it 'allows the author to update' do
      sign_in current_user
      patch post_path(published_post), params: { post: { title: 'Updated Title' } }

      expect(published_post.reload.title).to eq('Updated Title')
      expect(response).to redirect_to(post_path(published_post))
    end

    it 'prevents other users from updating' do
      sign_in other_user
      patch post_path(published_post), params: { post: { title: 'Hacked Title' } }

      expect(published_post.reload.title).not_to eq('Hacked Title')
      expect(response).to redirect_to(posts_path)
    end
  end

  describe 'DELETE /posts/:id (Destroy)' do
    it 'allows the author to delete' do
      sign_in current_user

      expect { delete post_path(published_post) }.to change(Post, :count).by(-1)
      expect(response).to redirect_to(user_path(current_user, format: :html))
    end

    it 'prevents other users from deleting' do
      sign_in other_user

      expect { delete post_path(published_post) }.not_to change(Post, :count)
      expect(response).to redirect_to(posts_path)
    end
  end
end
