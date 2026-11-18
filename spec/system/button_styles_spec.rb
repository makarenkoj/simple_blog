require 'rails_helper'

# Tailwind v4 puts utilities in @layer utilities. A stylesheet rule outside any layer beats
# every layered rule, so the legacy unlayered `button, [type='button'] { background-color:
# transparent }` erased bg-* utilities from every button (seen on the cookie banner's Accept
# and the profile form's Update, 2026-11-18).
RSpec.describe 'Button styles', type: :system do
  include_context 'base'

  before { driven_by(:selenium_chrome_headless) }

  def background_of(button)
    page.evaluate_script('getComputedStyle(arguments[0]).backgroundColor', button)
  end

  def transparent?(color) = ['rgba(0, 0, 0, 0)', 'transparent'].include?(color)

  it 'paints the cookie banner Accept button blue with white text' do
    visit root_path
    accept = find_button(I18n.t('cookies.accept'))

    expect(transparent?(background_of(accept))).to be(false)
    expect(page.evaluate_script('getComputedStyle(arguments[0]).color', accept)).to eq('rgb(255, 255, 255)')
  end

  it 'paints the profile form submit button with its background utility' do
    sign_in current_user
    visit edit_user_registration_path

    expect(transparent?(background_of(find('form button[type="submit"].bg-blue-600')))).to be(false)
  end
end
