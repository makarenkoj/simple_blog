require 'swagger_helper'

RSpec.describe 'Api::V1::Categories', type: :request do
  include_context 'base'

  path '/api/v1/categories' do
    get 'Get a list of categories' do
      tags 'Categories'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'successfully returns a list of categories' do
        let(:Authorization) { "Bearer #{ApiTokenService.generate!(current_user)}" }
        let!(:categories) { create_list(:category, 12) }

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string }
                 },
                 required: %w[id name]
               }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          expect(data.size).to eq(12)
          expect(data[0]['name']).to eq(categories.first.name)
        end
      end

      response '401', 'Unauthorized access' do
        let(:Authorization) { 'Bearer fake-token-123' }
        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
          expect(data['message']).to include('Unauthorized access')
        end
      end
    end
  end
end
