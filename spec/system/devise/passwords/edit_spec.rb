require 'rails_helper'

RSpec.describe 'User Password Reset (Update Password Form)', type: :system do
  include_context 'base'

  before do
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)
  end

  let(:raw_token) { current_user.send_reset_password_instructions }

  describe 'Change password' do
    before do
      visit edit_user_password_path(reset_password_token: raw_token, locale: locale)
    end

    it 'successfully changes the password when valid data is entered' do
      fill_in 'user_password', with: 'NewSecurePassword123!'
      fill_in 'user_password_confirmation', with: 'NewSecurePassword123!'

      click_button I18n.t('devise.passwords.edit.submit')

      expect(page).to have_current_path(root_path(locale: locale))
      expect(page).to have_content(I18n.t('devise.passwords.updated'))

      current_user.reload
      expect(current_user.valid_password?('NewSecurePassword123!')).to be true
    end

    it 'shows an error if passwords do not match' do
      fill_in 'user_password', with: 'NewSecurePassword123!'
      fill_in 'user_password_confirmation', with: 'OopsDifferentPassword123!'

      click_button I18n.t('devise.passwords.edit.submit')

      expect(page).to have_field('user_password')
      expect(page).to have_content(I18n.t('errors.messages.confirmation'))
    end
  end

  describe 'Invalid token handling' do
    it 'shows an error if the token is invalid or expired' do
      visit edit_user_password_path(reset_password_token: 'fake_invalid_token', locale: locale)

      fill_in 'user_password', with: 'NewSecurePassword123!'
      fill_in 'user_password_confirmation', with: 'NewSecurePassword123!'

      click_button I18n.t('devise.passwords.edit.submit')

      expect(page).to have_content(I18n.t('errors.messages.invalid'))
    end
  end

  describe 'Stimulus Password Visibility Controller (eyes)' do
    before do
      visit edit_user_password_path(reset_password_token: raw_token, locale: locale)
    end

    it 'toggles visibility for both fields independently' do
      password_input = find('#user_password')
      confirmation_input = find('#user_password_confirmation')

      password_btn = password_input.sibling('button')
      confirmation_btn = confirmation_input.sibling('button')

      expect(password_input['type']).to eq('password')
      expect(confirmation_input['type']).to eq('password')

      password_btn.click
      expect(password_input['type']).to eq('text')
      expect(confirmation_input['type']).to eq('password')

      confirmation_btn.click
      expect(password_input['type']).to eq('text')
      expect(confirmation_input['type']).to eq('text')

      password_btn.click
      expect(password_input['type']).to eq('password')
      expect(confirmation_input['type']).to eq('text')
    end
  end

  describe 'Navigation links' do
    before do
      visit edit_user_password_path(reset_password_token: raw_token, locale: locale)
    end

    it 'performs navigation to the sign-in page' do
      within('.mt-8') do
        click_link I18n.t('devise.shared.links.sign_in')
      end

      expect(page).to have_current_path(new_user_session_path(locale: locale))
    end
  end
end
