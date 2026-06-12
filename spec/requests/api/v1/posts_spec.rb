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
                  status: 'published',
                  category_ids: [category.id],
                  cover_image: fixture_file_upload('spec/fixtures/files/valid_test_image.png', 'image/png'),
                  body_html: <<~HTML
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
                  } }
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
        { post: { title: 'А', body_html: 'Мало', status: 'draft' } }
      end

      it 'does not create a post and returns 422 Unprocessable Entity with a list of errors' do
        expect { post '/api/v1/posts', params: invalid_params, headers: valid_headers }.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(data['errors']).to have_key('title')
        expect(data['errors']).to have_key('body_html')
      end
    end
  end
end
