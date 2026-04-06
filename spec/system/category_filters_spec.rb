require 'rails_helper'

RSpec.describe 'Category Page', type: :system do
  include_context 'base'

  let!(:creator) { create(:user, username: 'top_creator') }
  let!(:art_category) { create(:category, name: 'Art') }
  let!(:business_category) { create(:category, name: 'Business') }
  let!(:tech_category) { create(:category, name: 'Tech') }

  before do
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)

    create(:post, title: 'Art meets Business').tap do |post|
      post.categories << [art_category, business_category]
    end

    create(:post, title: 'Pure Art Post').tap do |post|
      post.categories << art_category
    end

    create(:post, title: 'Tech Only').tap do |post|
      post.categories << tech_category
    end

    sign_in current_user
  end

  describe 'Full Category Page & Translations' do
    before do
      page.current_window.resize_to(1440, 900)

      visit category_path(art_category, locale: :uk)
    end

    # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
    it 'displays all translations and elements correctly on the category page' do
      expect(page).not_to have_text(/translation missing/i)
      expect(page).to have_selector('h1', text: 'Art')
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.index.posts_in_category', count: 2))
      expect(page).to have_text(/#{I18n.t('activerecord.attributes.categories.popular')}/i)
      expect(page).to have_text(/#{I18n.t('activerecord.attributes.posts.index.posts')}/i)
      expect(page).to have_text(/#{I18n.t('activerecord.attributes.user.who_to_follow')}/i)

      if page.has_text?(creator.username)
        expect(page).to have_text(/#{I18n.t('followers')}/i)
        expect(page).to have_button(I18n.t('activerecord.attributes.user.follow'))
      end

      expect(page).to have_text(I18n.t('activerecord.attributes.posts.index.filter.filter'))

      click_button I18n.t('activerecord.attributes.posts.index.filter.filter')

      within("[data-dropdown-target='menu']") do
        expect(page).to have_text(I18n.t('activerecord.attributes.posts.index.filter.choose_category'))
        expect(page).to have_button(I18n.t('activerecord.attributes.posts.index.filter.show_results'))
        expect(page).not_to have_text(/translation missing/i)
      end
    end
    # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength

    it 'shows the correct initial posts for the category' do
      expect(page).to have_text('Art meets Business')
      expect(page).to have_text('Pure Art Post')
      expect(page).not_to have_text('Tech Only')
    end

    it 'shows only intersecting categories with correct counts in the dropdown' do
      click_button I18n.t('activerecord.attributes.posts.index.filter.filter')

      within("[data-dropdown-target='menu']") do
        expect(page).not_to have_text(/art/i)
        expect(page).not_to have_text(/tech/i)
        expect(page).to have_text(/business/i)

        business_label = find('label', text: /Business/i)
        expect(business_label).to have_css('span', text: '1')
      end
    end

    it 'filters posts when intersecting category is selected' do
      click_button I18n.t('activerecord.attributes.posts.index.filter.filter')

      within("[data-dropdown-target='menu']") do
        check "cat_#{business_category.id}"
        click_button I18n.t('activerecord.attributes.posts.index.filter.show_results')
      end

      expect(page).not_to have_text('Pure Art Post')
      expect(page).to have_text('Art meets Business')
      expect(page).to have_current_path(/category_ids/)
    end

    it 'shows empty state message when the category has no posts' do
      empty_cat = create(:category, name: 'EmptySpace')
      visit category_path(empty_cat, locale: :uk)

      expect(page).to have_text(I18n.t('activerecord.attributes.posts.no_posts_in_category'))
      expect(page).not_to have_text(/translation missing/i)
      expect(page).not_to have_css('#posts_list')
    end
  end
end
