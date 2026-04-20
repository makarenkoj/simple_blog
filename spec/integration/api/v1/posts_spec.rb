require 'swagger_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  include_context 'base'

  path '/api/v1/posts' do
    post 'Create a new article' do
      tags 'Posts'
      security [bearerAuth: []]
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: 'post[title]', in: :formData, type: :string, required: true
      parameter name: 'post[body]', in: :formData, type: :string, required: true
      parameter name: 'post[status]', in: :formData, type: :string, required: false, enum: %w[draft published archived]
      parameter name: 'post[cover_image]', in: :formData, type: :file, required: false
      parameter name: 'post[category_ids][]', in: :formData, type: :array, items: { type: :integer }, required: false

      response '201', 'The article was successfully created.' do
        let(:Authorization) { "Bearer #{ApiTokenService.generate!(current_user)}" }
        let(:category) { create(:category, name: 'API') }
        let(:'post[title]') { 'Valid Title' }
        let(:'post[body]') { 'This is a long enough body' }
        let(:'post[status]') { 'draft' }
        let(:'post[cover_image]') { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/valid_test_image.png').to_s, 'image/png') }
        let(:'post[category_ids][]') { [category.id] }

        schema type: :object, properties: { message: { type: :string }, post: { type: :object } }

        run_test! do |response|
          expect(response).to have_http_status(:created)
          expect(data['message']).to eq(I18n.t('activerecord.controllers.posts.created'))
          expect(data['post']['title']).to eq('Valid Title')
          expect(data['post']['slug']).to eq('valid-title')
          expect(data['post']['status']).to eq('draft')
          expect(data['post']['cover_url']).to include('valid_test_image.png')
          expect(Post.last.title).to eq('Valid Title')
          expect(Post.last.cover_image).to be_attached
        end
      end

      response '422', 'Validation error (invalid data)' do
        let(:Authorization) { "Bearer #{ApiTokenService.generate!(current_user)}" }

        let(:'post[title]') { 'IInvalid' }
        let(:'post[body]') { 'Short' }
        let(:'post[cover_image]') { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/valid_test_image.png').to_s, 'image/png') }

        schema type: :object, properties: { message: { type: :string }, errors: { type: :object } }

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          expect(data['errors']).to eq({ 'body' => [I18n.t('activerecord.errors.messages.post.title.short')] })
        end
      end

      response '401', 'Unauthorized access' do
        let(:Authorization) { 'Bearer fake-token-123' }
        let(:category) { create(:category, name: 'API') }
        let(:'post[title]') { 'Valid Title' }
        let(:'post[body]') { 'This is a long enough body' }
        let(:'post[status]') { 'draft' }
        let(:'post[cover_image]') { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/valid_test_image.png').to_s, 'image/png') }
        let(:'post[category_ids][]') { [category.id] }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
          expect(data['message']).to include('Unauthorized access')
        end
      end
    end
  end
end
