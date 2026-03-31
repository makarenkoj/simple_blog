require 'rails_helper'

RSpec.describe 'Post Creation Form', type: :system do
  include_context 'base'

  before do
    create(:category, name: 'Технології')
    create(:category, name: 'Новини')
    driven_by(:selenium_chrome_headless)
    sign_in current_user
  end

  describe 'Creating a new post' do
    before do
      visit new_post_path(locale: :uk)
    end

    it 'shows image preview when a cover image is selected' do
      attach_file(
        'post[cover_image]',
        Rails.root.join('spec/fixtures/files/valid_test_image.png'),
        make_visible: true
      )

      expect(page).to have_css('img[data-cover-image-preview-target="previewImage"][src]', visible: :all)
    end

    it 'successfully creates a post and saves it to the database' do
      fill_in 'post[title]', with: 'Мій перший системний тест'
      check 'технології', allow_label_click: true
      check 'новини', allow_label_click: true

      attach_file('post[cover_image]', Rails.root.join('spec/fixtures/files/valid_test_image.png'), make_visible: true)

      find('trix-editor').click
      find('trix-editor').send_keys('Це контент мого поста.')

      click_button 'Зберегти пост'

      expect(page).to have_content('Ви створили новий пост')
      expect(page).to have_content('Мій перший системний тест')

      created_post = Post.order(created_at: :desc).first

      expect(created_post.categories.count).to eq(2)
      expect(created_post.cover_image).to be_attached
    end

    it 'shows validation errors when submitting an empty form' do
      click_button 'Зберегти пост'

      expect(page).to have_css('.bg-red-50')
      expect(page).to have_content('Збереження не вдалося')
      expect(page).to have_content(/не може бути порожнім/i)
    end
  end
end
