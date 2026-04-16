require 'rails_helper'

RSpec.describe 'User Edit Profile Form', type: :system do
  include_context 'base'

  let!(:category2) { create(:category, name: 'Технології') }

  before do
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)
    create(:category, name: 'Новини')
    sign_in current_user
    visit edit_user_registration_path
  end

  describe 'Update profile' do
    it 'successfully updates basic information and categories provided the current password is entered' do
      fill_in 'user_first_name', with: 'Петро'
      fill_in 'user_username', with: 'petro_new'

      check category2.name

      fill_in 'user_current_password', with: 'Password123!'

      click_button I18n.t('simple_form.button.update')

      expect(page).to have_content(I18n.t('devise.registrations.updated'))

      current_user.reload
      expect(current_user.first_name).to eq('Петро')
      expect(current_user.username).to eq('petro_new')
      expect(current_user.preferred_category_ids).to include(category2.id)
    end

    it 'does not allow updating profile without entering current password' do
      fill_in 'user_first_name', with: 'Петро'

      click_button I18n.t('simple_form.button.update')

      expect(page).to have_css('form.edit_user')
      expect(page).to have_content('не може бути пустим')

      current_user.reload
      expect(current_user.first_name).to eq('Yura')
    end

    it 'allows successfully changing the password' do
      fill_in 'user_password', with: 'NewSuperSecret456!'
      fill_in 'user_password_confirmation', with: 'NewSuperSecret456!'
      fill_in 'user_current_password', with: 'Password123!'

      click_button I18n.t('simple_form.button.update')

      expect(page).to have_content(I18n.t('devise.registrations.updated'))

      current_user.reload
      expect(current_user.valid_password?('NewSuperSecret456!')).to be true
    end
  end

  describe 'Stimulus Password Visibility Controller (eyes)' do
    it 'independently toggles visibility for each of the three password fields' do
      new_password_input = find('#user_password')
      confirmation_input = find('#user_password_confirmation')
      current_password_input = find('#user_current_password')
      new_password_btn = new_password_input.sibling('button')
      confirmation_input.sibling('button')
      current_password_btn = current_password_input.sibling('button')

      expect(new_password_input['type']).to eq('password')
      expect(confirmation_input['type']).to eq('password')
      expect(current_password_input['type']).to eq('password')

      new_password_btn.click
      expect(new_password_input['type']).to eq('text')
      expect(confirmation_input['type']).to eq('password')
      expect(current_password_input['type']).to eq('password')

      current_password_btn.click
      expect(new_password_input['type']).to eq('text')
      expect(confirmation_input['type']).to eq('password')
      expect(current_password_input['type']).to eq('text')

      new_password_btn.click
      expect(new_password_input['type']).to eq('password')
      expect(current_password_input['type']).to eq('text')
    end
  end

  describe 'Account deletion' do
    it 'allows the user to delete their account' do
      accept_confirm do
        click_button I18n.t('simple_form.labels.defaults.cancel')
      end

      expect(page).to have_current_path(root_path(locale: locale))
      expect(page).to have_content(I18n.t('devise.registrations.destroyed'))
      expect(User).not_to exist(current_user.id)
    end
  end
end
