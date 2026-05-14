require 'rails_helper'

RSpec.describe 'Category Cards interaction', type: :system do
  include_context 'base'

  let!(:category) { create(:category, name: 'Ruby') }
  let(:locale) { :uk }

  before do
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)
  end

  describe 'Unauthenticated user' do
    before { visit categories_path(locale: locale) }

    it 'navigates to category show page when clicking the card itself' do
      find("[data-controller='category-card']").click

      expect(page).not_to have_content('Категорію не знайдено!')
      expect(page).to have_current_path(category_path(category, locale: locale))
      expect(page).to have_selector('h1', text: 'Ruby', wait: 2)
    end

    it "does not navigate to category when clicking 'Sign in to subscribe'" do
      within("[data-controller='category-card']") do
        click_link I18n.t('activerecord.attributes.posts.sign_in_to_subscribe', locale: locale)
      end

      expect(page).to have_current_path(new_user_session_path(locale: locale))
    end
  end

  describe 'Authenticated user' do
    before do
      sign_in current_user
      visit categories_path(locale: locale)
    end

    it 'subscribes but stays on the same page when clicking the subscribe button' do
      within("[data-controller='category-card']") do
        find('.z-30 form button').click
      end

      expect(page).to have_content('Підписані на категорію ruby')
      expect(page).to have_current_path(categories_path(locale: locale))
      expect(current_user.category_preferences.count).to eq(1)
    end
  end
end
