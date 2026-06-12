require 'swagger_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  include_context 'base'

  let(:valid_body) do
    <<~HTML
      <h2>Тестування TipTap Editor</h2>
      <p>Це базовий абзац, у якому ми перевіряємо <strong>жирний текст</strong>, <em>курсив</em>, <u>підкреслення</u> та <s>закреслений текст</s>.</p>

      <h3>Списки та вирівнювання</h3>
      <p style="text-align: center">Цей текст вирівняно по центру.</p>
      <p><a href="https://tiptap.dev" target="_blank" class="text-emerald-600 underline hover:text-emerald-800 transition-colors cursor-pointer">Це посилання на документацію TipTap</a>.</p>
      <p>А ось так виглядає <span style="color: #10b981">кольоровий текст (emerald)</span>.</p>

      <ul class="list-disc ml-6 space-y-1 my-4">
        <li class="pl-1">Перший елемент маркованого списку</li>
        <li class="pl-1">Другий елемент
          <ul class="list-disc ml-6 space-y-1 my-4">
            <li class="pl-1">Вкладений елемент списку</li>
          </ul>
        </li>
      </ul>

      <ol class="list-decimal ml-6 space-y-1 my-4">
        <li class="pl-1">Перший крок нумерованого списку</li>
        <li class="pl-1">Другий крок</li>
      </ol>

      <h3>Блок коду</h3>
      <pre><code>def hello_world
        puts "TipTap працює ідеально!"
      end</code></pre>

      <h3>Таблиця</h3>
      <table class="min-w-full border-collapse border border-slate-300 my-4">
        <thead>
          <tr>
            <th class="border border-slate-300 bg-slate-100 p-2 font-bold">Технологія</th>
            <th class="border border-slate-300 bg-slate-100 p-2 font-bold">Тип</th>
            <th class="border border-slate-300 bg-slate-100 p-2 font-bold">Статус</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="border border-slate-300 p-2">Ruby on Rails</td>
            <td class="border border-slate-300 p-2">Backend</td>
            <td class="border border-slate-300 p-2">Активно</td>
          </tr>
          <tr>
            <td class="border border-slate-300 p-2">TipTap</td>
            <td class="border border-slate-300 p-2">Frontend Editor</td>
            <td class="border border-slate-300 p-2">Інтегровано</td>
          </tr>
        </tbody>
      </table>

      <h3>Зображення</h3>
      <img src="https://placehold.co/600x300/e2e8f0/1e293b?text=Test+Image" class="max-w-full h-auto rounded-lg my-4" alt="Test placeholder">
    HTML
  end

  path '/api/v1/posts' do
    post 'Create a new article' do
      tags 'Posts'
      security [bearerAuth: []]
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: 'post[title]', in: :formData, type: :string, required: true
      parameter name: 'post[body_html]', in: :formData, type: :string, required: true
      parameter name: 'post[status]', in: :formData, type: :string, required: false, enum: %w[draft published archived]
      parameter name: 'post[cover_image]', in: :formData, type: :file, required: false
      parameter name: 'post[category_ids][]', in: :formData, type: :array, items: { type: :integer }, required: false

      response '201', 'The article was successfully created.' do
        let(:Authorization) { "Bearer #{ApiTokenService.generate!(current_user)}" }
        let(:category) { create(:category, name: 'API') }
        let(:'post[title]') { 'Valid Title' }
        let(:'post[body_html]') { valid_body }
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
        let(:'post[body_html]') { 'Short' }
        let(:'post[cover_image]') { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/valid_test_image.png').to_s, 'image/png') }

        schema type: :object, properties: { message: { type: :string }, errors: { type: :object } }

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          expect(data['errors']).to eq({ 'body_html' => [I18n.t('activerecord.errors.messages.post.title.short')] })
        end
      end

      response '401', 'Unauthorized access' do
        let(:Authorization) { 'Bearer fake-token-123' }
        let(:category) { create(:category, name: 'API') }
        let(:'post[title]') { 'Valid Title' }
        let(:'post[body_html]') { 'This is a long enough body' }
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
