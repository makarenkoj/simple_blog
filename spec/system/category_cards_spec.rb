require 'rails_helper'

RSpec.describe 'Category Cards interaction', type: :system do
  include_context 'base'

  let!(:category) { create(:category, name: 'Ruby') }

  before do
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)
  end

  describe 'Unauthenticated user' do
    before { visit categories_path }

    it 'navigates to category show page when clicking the card itself' do
      find("[data-controller='category-card']").click

      expect(page).not_to have_content('Категорію не знайдено!')
      expect(page).to have_current_path(category_path(category))
      expect(page).to have_selector('h1', text: 'Ruby', wait: 2)
    end

    it "does not navigate to category when clicking 'Sign in to subscribe'" do
      within("[data-controller='category-card']") do
        click_link I18n.t('activerecord.attributes.posts.sign_in_to_subscribe')
      end

      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe 'Authenticated user' do
    before do
      sign_in current_user
      visit categories_path
    end

    it 'subscribes but stays on the same page when clicking the subscribe button' do
      within("[data-controller='category-card']") do
        find('.z-30 form button').click
      end

      expect(page).to have_content(I18n.t('activerecord.attributes.categories.preferences.subscribed', category: category.name))
      expect(page).to have_current_path(categories_path)
      expect(current_user.category_preferences.count).to eq(1)
    end
  end
end
