require 'rails_helper'

RSpec.describe 'Search', type: :system do
  include_context 'base'

  let!(:search_user) { create(:user, username: 'rubymaster', first_name: 'Ruby', last_name: 'Guru') }

  before do
    driven_by(:selenium_chrome_headless)
    page.current_window.resize_to(1440, 900)

    create(:category, name: 'Ruby Programming')
    create(:post, status: :published, title: 'Advanced Ruby Tips', user: search_user)
    create(:post, status: :draft, title: 'My Ruby Draft', user: current_user)
    create(:post, status: :draft, title: 'Other Ruby Draft', user: search_user)
  end

  describe 'Full Page Search (HTML)' do
    it 'displays matched categories, users, and published posts' do
      visit search_path(query: 'Ruby')

      expect(page).to have_content(I18n.t('search.search_results_for'))
      expect(page).to have_content(/Ruby Programming/i)
      expect(page).to have_content(/Ruby Guru/i)
      expect(page).to have_content(/@rubymaster/i)
      expect(page).to have_content(/Advanced Ruby Tips/i)
    end

    it 'shows empty state when no results found' do
      visit search_path(query: 'UnicornsAndRainbows')

      expect(page).to have_content(I18n.t('search.search_no_results'))
      expect(page).to have_content(I18n.t('search.try_different_keywords'))

      expect(page).not_to have_selector('h2', text: I18n.t('categories'))
      expect(page).not_to have_selector('h2', text: I18n.t('posts'))
    end

    describe 'Privacy rules for Drafts' do
      it 'hides drafts from guests' do
        visit search_path(query: 'Draft')

        expect(page).to have_content(I18n.t('search.search_no_results'))
        expect(page).not_to have_content(/My Ruby Draft/i)
        expect(page).not_to have_content(/Other Ruby Draft/i)
      end

      it 'shows own drafts to the author, but hides others' do
        sign_in current_user
        visit search_path(query: 'Draft')

        expect(page).to have_content(/My Ruby Draft/i)
        expect(page).not_to have_content(/Other Ruby Draft/i)
      end
    end
  end

  describe 'Live Dropdown Search (Turbo Frame)', :js do
    it 'displays instant results in the navbar dropdown' do
      visit root_path
      fill_in 'query', with: 'Ruby', match: :first

      within('#search_results') do
        expect(page).to have_content(/Ruby Programming/i)
        expect(page).to have_content(/Ruby Guru/i)
        expect(page).to have_content(/Advanced Ruby Tips/i)
        expect(page).to have_link(I18n.t('search.all_results'), href: search_path(query: 'Ruby'))
      end
    end

    it 'shows compact empty state in the dropdown' do
      visit root_path

      fill_in 'query', with: 'Unicorn', match: :first

      within('#search_results') do
        expect(page).to have_content(I18n.t('search.search_no_results'))
        expect(page).to have_content(I18n.t('search.try_different_query'))
      end
    end

    it 'does not show dropdown for queries less than 2 characters' do
      visit root_path
      fill_in 'query', with: 'R', match: :first

      expect(page).to have_css('#search_results', exact_text: '', visible: :all)
    end
  end
end
