require 'rails_helper'

RSpec.describe 'Posts Index Page (Feed, Library, Category)', type: :system do
  let!(:creator) { create(:user, :creator, username: 'snail_bob') }
  let!(:reader) { create(:user, username: 'reader_alice') }
  let!(:tech_category) { create(:category, name: 'Technology') }
  let!(:art_category) { create(:category, name: 'Art') }

  before do
    driven_by(:selenium_chrome_headless)
    page.current_window.resize_to(1440, 900)
  end

  describe 'General Feed (PostsController#index)' do
    context 'when there are posts' do
      before do
        create_list(:post, 6, status: :published, title: 'Pagination Test Post', user: creator, categories: [tech_category])
      end

      it 'displays the posts and handles pagination via Turbo Stream', :js do
        visit posts_path

        expect(page).to have_content('Pagination Test Post', count: 5)
        expect(page).to have_link(I18n.t('activerecord.attributes.posts.index.load_more'))

        click_link I18n.t('activerecord.attributes.posts.index.load_more')

        expect(page).to have_content('Pagination Test Post', count: 6)
        expect(page).not_to have_link(I18n.t('activerecord.attributes.posts.index.load_more'))
      end

      it 'displays the sidebar with popular categories and creators' do
        visit posts_path

        within('aside') do
          expect(page).to have_content(/#{I18n.t('activerecord.attributes.categories.popular')}/i)
          expect(page).to have_content('Technology')
          expect(page).to have_content(/#{I18n.t('activerecord.attributes.user.who_to_follow')}/i)
          expect(page).to have_content('snail_bob')
        end
      end
    end

    context 'when filtering by category' do
      before do
        create(:post, status: :published, title: 'Ruby on Rails Guide', categories: [tech_category])
        create(:post, status: :published, title: 'Painting 101', categories: [art_category])
      end

      it 'filters posts correctly using the dropdown', :js do
        visit posts_path

        expect(page).to have_content('Ruby on Rails Guide')
        expect(page).to have_content('Painting 101')

        click_button I18n.t('activerecord.attributes.posts.index.filter.filter')

        check "cat_#{tech_category.id}"

        click_button I18n.t('activerecord.attributes.posts.index.filter.show_results')

        expect(page).to have_content('Ruby on Rails Guide')
        expect(page).not_to have_content('Painting 101')
      end
    end

    context 'when there are no posts (Empty State)' do
      it 'shows empty state and "Create Post" button ONLY for creators' do
        visit posts_path
        expect(page).to have_content(I18n.t('activerecord.attributes.posts.index.no_posts'))
        expect(page).not_to have_content(I18n.t('activerecord.attributes.posts.index.create_one'))

        sign_in reader
        visit posts_path
        expect(page).not_to have_content(I18n.t('activerecord.attributes.posts.index.create_one'))

        sign_in creator
        visit posts_path
        expect(page).to have_content(I18n.t('activerecord.attributes.posts.index.create_one'))
        expect(page).to have_link(I18n.t('activerecord.attributes.posts.index.new_post'), href: new_post_path)
      end
    end
  end

  describe 'Category Show Page (CategoriesController#show)' do
    before do
      create(:post, status: :published, title: 'Tech News', categories: [tech_category])
    end

    it 'displays posts for the specific category and correct headers' do
      visit category_path(tech_category)

      expect(page).to have_selector('h1', text: 'Technology')
      expect(page).to have_content('Tech News')
    end
  end

  describe 'Library Page (PostsController#library)' do
    let(:bookmarked_post) { create(:post, status: :published, title: 'Saved Post') }

    before do
      create(:post, status: :published, title: 'Not Saved Post')
      create(:bookmark, user: reader, post: bookmarked_post)
    end

    it 'requires authentication' do
      visit library_posts_path
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'displays only bookmarked posts for the signed-in user' do
      sign_in reader
      visit library_posts_path

      expect(page).to have_selector('h1', text: I18n.t('activerecord.attributes.posts.library'))
      expect(page).to have_content('Saved Post')
      expect(page).not_to have_content('Not Saved Post')
    end
  end
end
