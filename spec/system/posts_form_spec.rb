require 'rails_helper'

RSpec.describe 'Post Creation Form', type: :system do
  include_context 'base'

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
      attach_file(
        'post[cover_image]',
        Rails.root.join('spec/fixtures/files/valid_test_image.png'),
        make_visible: true
      )

      expect(page).to have_css('img[data-cover-image-preview-target="previewImage"][src]', visible: :all)
    end

    it 'successfully creates a post and saves it to the database' do
      fill_in 'post[title]', with: 'My first system test'
      check 'technology', allow_label_click: true
      check 'news', allow_label_click: true

      attach_file('post[cover_image]', Rails.root.join('spec/fixtures/files/valid_test_image.png'), make_visible: true)

      find('trix-editor').click
      find('trix-editor').send_keys('This is the content of my post.')

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

    # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
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
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.categories_hint'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.body_hint'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.attachments_hint'))
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.back'))
      expect(page).to have_button(I18n.t('activerecord.attributes.posts.save'))

      expect(page).to have_field('post[title]', placeholder: I18n.t('activerecord.attributes.posts.title_placeholder'))
      expect(page).to have_css("trix-editor[placeholder='#{I18n.t('activerecord.attributes.posts.body_placeholder')}']")
      expect(page).to have_css("button[title='#{I18n.t('post.editor.toolbar.bold')}']")
      expect(page).to have_css("button[title='#{I18n.t('post.editor.toolbar.link')}']")

      click_button I18n.t('activerecord.attributes.posts.save')

      expect(page).not_to have_text(/translation missing/i)
      expect(page).to have_css('.bg-red-50')

      error_message_pattern = I18n.t('post.errors.messages.not_saved', count: 3)

      expect(page).to have_text(error_message_pattern)
    end
    # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
  end
end
