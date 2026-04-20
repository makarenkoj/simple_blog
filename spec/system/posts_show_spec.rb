require 'rails_helper'

RSpec.describe 'Post Show Page', type: :system do
  include_context 'base'

  let(:author) { create(:user, username: 'super_author') }
  let(:reader) { create(:user, username: 'just_reader') }
  let(:category) { create(:category, name: 'Технології') }
  let!(:main_post) do
    create(:post,
           user: author,
           title: 'Головна тестова стаття',
           body: 'Це дуже цікавий контент нашої статті.',
           status: :published)
  end

  before do
    driven_by(:selenium_chrome_headless)

    main_post.categories << category
    main_post.cover_image.attach(io: File.open(Rails.root.join('spec/fixtures/files/valid_test_image.png')), filename: 'test.png', content_type: 'image/png')

    create_list(:post, 3, user: author, status: :published)
  end

  describe 'Viewing as a Guest (Unauthenticated)' do
    before { visit post_path(main_post, locale: :uk) }

    it 'displays all post content correctly' do
      expect(page).not_to have_text(/translation missing/i)
      expect(page).to have_selector('h1', text: 'Головна тестова стаття')
      expect(page).to have_text('Це дуже цікавий контент нашої статті.')
      expect(page).to have_text(/Технології/i)
      expect(page).to have_text('super_author')
      expect(page).to have_css("img[alt='Головна тестова стаття']")
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.more_from_author', author: author.username))
    end

    it 'does NOT show admin controls or status dropdown' do
      expect(page).not_to have_text(I18n.t('activerecord.attributes.posts.admin_mode'))
      expect(page).not_to have_button(I18n.t('activerecord.attributes.posts.change_status_title'))
    end
  end

  describe 'Viewing as another Authenticated User (Reader)' do
    before do
      sign_in reader
      visit post_path(main_post, locale: :uk)
    end

    it 'does NOT show admin controls or status dropdown for other users posts' do
      expect(page).not_to have_text(I18n.t('activerecord.attributes.posts.admin_mode'))
      expect(page).not_to have_button(I18n.t('activerecord.attributes.posts.change_status_title'))
    end
  end

  describe 'Viewing as the Author' do
    before do
      sign_in author
      visit post_path(main_post, locale: :uk)
    end

    it 'shows admin controls and edit/destroy links' do
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.admin_mode'))
      expect(page).to have_link(I18n.t('activerecord.attributes.posts.edit'))
      expect(page).to have_link(I18n.t('activerecord.attributes.posts.destroy'))
    end

    it 'successfully changes the post status using the dropdown menu' do
      published_text = I18n.t('activerecord.attributes.posts.status_badge.published')
      expect(page).to have_button(text: /#{published_text}/i)

      find("button[title='#{I18n.t('activerecord.attributes.posts.change_status_title')}']").click

      draft_option_text = I18n.t('activerecord.attributes.posts.statuses.draft')
      click_button draft_option_text

      draft_badge_text = I18n.t('activerecord.attributes.posts.status_badge.draft')

      expect(page).to have_button(text: /#{draft_badge_text}/i)
      expect(main_post.reload.draft?).to be true
    end
  end
end
