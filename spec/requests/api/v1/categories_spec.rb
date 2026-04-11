require 'rails_helper'

RSpec.describe 'Api::V1::Categories', type: :request do
  include_context 'base'

  let(:valid_headers) do
    token = ApiTokenService.generate!(current_user)
    { 'Authorization': "Bearer #{token}" }
  end

  before do
    create_list(:category, 10)
  end

  describe 'GET /api/v1/categories' do
    context 'SECURITY: unauthorized access' do
      it 'returns 401 Unauthorized if no token is provided' do
        get '/api/v1/categories', headers: {}
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns 401 Unauthorized if token is invalid' do
        get '/api/v1/categories', headers: { 'Authorization': 'Bearer fake-token' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns 401 Unauthorized if token has expired' do
        token = ApiTokenService.generate!(current_user, expires_in: 1.day)

        travel 2.days do
          get '/api/v1/categories', headers: { 'Authorization': "Bearer #{token}" }

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'SUCCESS: authorized access' do
      it 'returns a list of categories and 200 OK' do
        get '/api/v1/categories', headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(data).to be_an(Array)
        expect(data.length).to eq(10)

        category_data = data[0]
        expect(category_data['id']).to be_present
        expect(category_data['name']).to be_present
      end
    end
  end
end
