require 'rails_helper'

RSpec.describe 'Post Creation Form', type: :system do
  include_context 'base'

  let(:body_content) do
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

  before do
    create(:category, name: 'Technology')
    create(:category, name: 'News')
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)
    sign_in current_user
  end

  describe 'Creating a new post' do
    before do
      visit new_post_path
    end

    it 'shows image preview when a cover image is selected' do
      find('input[name="post[cover_image]"]', visible: :hidden).set(Rails.root.join('spec/fixtures/files/valid_test_image.png'))

      expect(page).to have_css('img[data-cover-image-preview-target="previewImage"][src]', visible: :all)
    end

    it 'successfully creates a post and saves it to the database' do
      fill_in 'post[title]', with: 'My first system test'
      check 'technology', allow_label_click: true
      check 'news', allow_label_click: true

      attach_file('post[cover_image]', Rails.root.join('spec/fixtures/files/valid_test_image.png'), make_visible: true)

      find('.ProseMirror').click
      find('.ProseMirror').send_keys(body_content)

      select I18n.t('activerecord.attributes.posts.statuses.published'), from: 'post[status]'

      click_button 'Save'

      expect(page).to have_content('You created a new post')
      expect(page).to have_content('My first system test')

      created_post = Post.order(created_at: :desc).first

      expect(created_post.categories.count).to eq(2)
      expect(created_post.cover_image).to be_attached
      expect(created_post.status).to eq('published')
    end

    it 'shows validation errors when submitting an empty form' do
      click_button 'Save'

      expect(page).to have_css('.bg-red-50')
      expect(page).to have_content('Save failed')
      expect(page).to have_content(/can't be blank/i)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'displays all translations correctly on the page including flash messages' do
      expect(page).not_to have_text(/translation missing/i)
      expect(page).to have_text(I18n.t('activerecord.controllers.posts.new'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.cover_image'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.title'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.categories'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.body'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.status'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.status_hint'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.statuses.draft'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.statuses.published'))
      expect(page).to have_text(I18n.t('buttons.click_to_upload'))
      expect(page).to have_text(I18n.t('buttons.image_formats'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.back'))
      expect(page).to have_button(I18n.t('activerecord.attributes.posts.save'))
      expect(page).to have_field('post[title]', placeholder: I18n.t('activerecord.attributes.posts.title_placeholder'))
      expect(page).to have_css('[data-controller="tiptap"]')
      expect(page).to have_css("button[data-action='click->tiptap#toggleBold']")
      expect(page).to have_css("button[data-action='click->tiptap#setLink']")

      click_button I18n.t('activerecord.attributes.posts.save')

      expect(page).not_to have_text(/translation missing/i)
      expect(page).to have_css('.bg-red-50')

      error_message_pattern = I18n.t('post.errors.messages.not_saved', count: 3)

      expect(page).to have_text(error_message_pattern)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
