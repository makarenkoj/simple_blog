require 'rails_helper'

RSpec.describe 'User Registration', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'displays all translations correctly on the page including error states' do
    visit new_user_registration_path
    click_button I18n.t('cookies.accept') if page.has_button?(I18n.t('cookies.accept'))

    expect(page).not_to have_text(/translation missing/i)
    expect(page).to have_selector('h2', text: I18n.t('activerecord.attributes.user.sign_up'))
    expect(page).to have_text(I18n.t('activerecord.attributes.user.avatar'))
    expect(page).to have_text(I18n.t('activerecord.attributes.user.first_name'))
    expect(page).to have_text(I18n.t('activerecord.attributes.user.last_name'))
    expect(page).to have_text(I18n.t('activerecord.attributes.user.username'))
    expect(page).to have_text(I18n.t('activerecord.attributes.user.email'))
    expect(page).to have_text(I18n.t('activerecord.attributes.user.password'))
    expect(page).to have_text(I18n.t('activerecord.attributes.user.password_confirmation'))
    expect(page).to have_button(I18n.t('activerecord.attributes.user.sign_up'))

    click_button I18n.t('activerecord.attributes.user.sign_up')

    expect(page).not_to have_text(/translation missing/i)
  end
  # rubocop:enable RSpec/MultipleExpectations

  it 'allows a user to sign up' do
    visit new_user_registration_path

    click_button I18n.t('cookies.accept')

    fill_in 'Email', with: 'newuser@example.com'
    fill_in 'user[username]', with: 'superdev'
    fill_in 'user[first_name]', with: 'Ivan'
    fill_in 'user[last_name]', with: 'Franko'
    fill_in 'user[password]', with: 'password123'
    fill_in 'user[password_confirmation]', with: 'password123'

    click_button I18n.t('activerecord.attributes.user.sign_up')

    expect(page).to have_content(I18n.t('devise.registrations.signed_up'))
    expect(User.count).to eq(1)
  end
end
