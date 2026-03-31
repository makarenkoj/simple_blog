require 'rails_helper'

RSpec.describe 'Category Post Filtering', type: :system do
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
  end

  describe 'Contextual filters on Category page' do
    before do
      visit category_path(art_category, locale: :uk)
    end

    it 'shows the correct initial posts for the category' do
      expect(page).to have_content('Art meets Business')
      expect(page).to have_content('Pure Art Post')
      expect(page).not_to have_content('Tech Only')
    end

    it 'shows only intersecting categories with correct counts in the dropdown' do
      click_button I18n.t('activerecord.attributes.posts.index.filter.filter', locale: :uk)

      within("[data-dropdown-target='menu']") do
        expect(page).not_to have_text('art', exact: true)
        expect(page).not_to have_text('tech')
        expect(page).to have_text('business')

        business_label = find('label', text: 'business')
        expect(business_label).to have_css('span.rounded-full', text: '1')
      end
    end

    it 'filters posts when intersecting category is selected' do
      click_button I18n.t('activerecord.attributes.posts.index.filter.filter', locale: :uk)

      within("[data-dropdown-target='menu']") do
        check "cat_#{business_category.id}"
        click_button I18n.t('activerecord.attributes.posts.index.filter.show_results', locale: :uk)
      end

      expect(page).to have_current_path(/category_ids/)
      expect(page).to have_content('Art meets Business')
      expect(page).not_to have_content('Pure Art Post')
    end
  end
end
