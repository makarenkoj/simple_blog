require 'rails_helper'

RSpec.describe 'User Forgot Password Form (Request Instructions)', type: :system do
  include_context 'base'

  before do
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)
    visit new_user_password_path
  end

  describe 'Sending instructions' do
    it 'successfully sends the email if the email exists in the database' do
      fill_in 'user_email', with: current_user.email

      expect do
        click_button I18n.t('devise.passwords.new.submit')
        expect(page).to have_content(I18n.t('devise.passwords.send_instructions'))
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(page).to have_current_path(new_user_session_path(locale: locale))
    end

    it 'shows an error if email not found' do
      fill_in 'user_email', with: 'not_found@example.com'

      expect do
        click_button I18n.t('devise.passwords.new.submit')
        expect(page).to have_content(I18n.t('errors.messages.not_found'))
      end.not_to(change { ActionMailer::Base.deliveries.count })

      expect(page).to have_css('form#new_user')
    end

    it 'shows an error if email is blank' do
      fill_in 'user_email', with: ''
      click_button I18n.t('devise.passwords.new.submit')

      expect(page).to have_css('form#new_user')
      expect(page).to have_content(I18n.t('errors.messages.blank'))
    end
  end

  describe 'Navigation links' do
    it 'goes to the sign in page' do
      within('.mt-8') do
        click_link I18n.t('devise.shared.links.sign_in')
      end

      expect(page).to have_current_path(new_user_session_path(locale: locale))
    end

    it 'goes to the sign up page' do
      within('.mt-8') do
        click_link I18n.t('devise.shared.links.sign_up')
      end

      expect(page).to have_current_path(new_user_registration_path(locale: locale))
    end
  end
end
