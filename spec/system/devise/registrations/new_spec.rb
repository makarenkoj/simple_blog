require 'rails_helper'

RSpec.describe 'User Registrations', type: :system do
  include_context 'base'

  before do
    driven_by(:selenium_chrome_headless)
  end

  describe 'Sign Up Form' do
    before do
      visit new_user_registration_path
    end

    it 'allows the user to successfully register with an avatar' do
      fill_in 'user_first_name', with: 'Олександр'
      fill_in 'user_last_name', with: 'Довженко'
      fill_in 'user_username', with: 'alex_dov'
      fill_in 'user_email', with: 'alex@example.com'
      fill_in 'user_password', with: 'SecretPass123!'
      fill_in 'user_password_confirmation', with: 'SecretPass123!'

      attach_file 'user_avatar', Rails.root.join('spec/fixtures/files/valid_test_image.png')

      expect { click_button I18n.t('activerecord.attributes.user.sign_up') }.to change(User, :count).by(1)
      expect(page).to have_current_path(root_path(locale: locale))
      expect(page).to have_content(I18n.t('devise.registrations.signed_up'))
      expect(User.last.avatar).to be_attached
    end

    it 'shows errors when invalid data is entered' do
      fill_in 'user_password', with: 'password123'
      fill_in 'user_password_confirmation', with: 'wrongpassword'

      expect { click_button I18n.t('activerecord.attributes.user.sign_up') }.not_to change(User, :count)
      expect(page).to have_css('.bg-red-100.text-red-700')
      expect(page).to have_content(I18n.t('errors.messages.blank'))
      expect(page).to have_content(I18n.t('errors.messages.confirmation'))
    end

    it 'toggles password visibility when clicking on the icon (eye)' do
      password_input = find('#user_password')

      expect(password_input['type']).to eq('password')

      toggle_button = find('#user_password').sibling('button')
      toggle_button.click

      expect(password_input['type']).to eq('text')

      toggle_button.click

      expect(password_input['type']).to eq('password')
    end

    it 'toggles the visibility of password confirmation independent of the master password' do
      password_input = find('#user_password')
      confirmation_input = find('#user_password_confirmation')
      confirmation_toggle_button = find('#user_password_confirmation').sibling('button')
      confirmation_toggle_button.click

      expect(password_input['type']).to eq('password')
      expect(confirmation_input['type']).to eq('text')
    end
  end
end
