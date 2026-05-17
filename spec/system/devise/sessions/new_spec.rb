require 'rails_helper'

RSpec.describe 'User Sign In Form', type: :system do
  include_context 'base'

  before do
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)
    visit new_user_session_path
  end

  describe 'Authentication' do
    it 'allows the user to successfully sign in with correct credentials' do
      fill_in 'user_email', with: current_user.email
      fill_in 'user_password', with: 'Password123!'

      check I18n.t('devise.sessions.new.remember_me') if page.has_field?('user_remember_me')

      click_button I18n.t('devise.sessions.new.sign_in')

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(I18n.t('devise.sessions.signed_in'))
    end

    it 'shows error when incorrect password is entered' do
      fill_in 'user_email', with: current_user.email
      fill_in 'user_password', with: 'WrongPassword!'

      click_button I18n.t('devise.sessions.new.sign_in')

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content(I18n.t('devise.failure.invalid', authentication_keys: 'email'))
    end
  end

  describe 'Stimulus Password Visibility Controller (eyes)' do
    it 'successfully toggles the visibility of the password field' do
      password_input = find('#user_password')
      toggle_btn = password_input.sibling('button')

      expect(password_input['type']).to eq('password')

      toggle_btn.click
      expect(password_input['type']).to eq('text')

      toggle_btn.click
      expect(password_input['type']).to eq('password')
    end
  end

  describe 'Navigation links' do
    it 'navigates to the registration page' do
      click_link I18n.t('devise.shared.links.sign_up')
      expect(page).to have_current_path(new_user_registration_path)
    end

    it 'navigates to the password reset page' do
      click_link I18n.t('devise.shared.links.forgot_your_password')
      expect(page).to have_current_path(new_user_password_path)
    end
  end
end
