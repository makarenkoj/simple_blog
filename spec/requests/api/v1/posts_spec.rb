require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  include_context 'base'

  let(:category) { create(:category, name: 'API Категорія') }
  let(:valid_headers) do
    token = ApiTokenService.generate!(current_user)
    { 'Authorization': "Bearer #{token}" }
  end

  describe 'POST /api/v1/posts' do
    context 'SECURITY: unauthorized access' do
      it 'returns 401 Unauthorized if no token is provided' do
        post '/api/v1/posts', params: { post: { title: 'Test' } }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns 401 Unauthorized if token is invalid' do
        post '/api/v1/posts', params: { post: { title: 'Test' } }, headers: { 'Authorization': 'Bearer fake-token' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns 401 Unauthorized if token has expired' do
        token = ApiTokenService.generate!(current_user, expires_in: 1.day)

        travel 2.days do
          post '/api/v1/posts', params: { post: { title: 'Test' } }, headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'SUCCESS: authorized access with valid data' do
      let(:valid_params) do
        { post: { title: 'Супер крута стаття через API',
                  body: 'Це текст статті, який має бути більшим за 10 символів, щоб пройти валідацію.',
                  status: 'published',
                  category_ids: [category.id],
                  cover_image: fixture_file_upload('spec/fixtures/files/valid_test_image.png', 'image/png') } }
      end

      it 'creates a post, attaches an image and returns 201 Created and JSON' do
        expect { post '/api/v1/posts', params: valid_params, headers: valid_headers }.to change(Post, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(data['message']).to be_present

        post_data = data['post']
        expect(post_data['title']).to eq('Супер крута стаття через API')
        expect(post_data['status']).to eq('published')
        expect(post_data['category_ids']).to include(category.id)
        expect(post_data['cover_url']).to include('valid_test_image.png')
      end
    end

    context 'ERROR: authorized access with invalid data' do
      let(:invalid_params) do
        { post: { title: 'А', body: 'Мало', status: 'draft' } }
      end

      it 'does not create a post and returns 422 Unprocessable Entity with a list of errors' do
        expect { post '/api/v1/posts', params: invalid_params, headers: valid_headers }.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(data['errors']).to have_key('title')
        expect(data['errors']).to have_key('body')
      end
    end
  end
end
