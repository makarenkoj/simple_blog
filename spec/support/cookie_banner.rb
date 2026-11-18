# The cookie consent banner is fixed to the bottom of the viewport and slides in ~100-400 ms
# after a page loads. In the short headless window it can cover controls at the bottom of
# a page (it fully covers "Delete account" there), so a click made while it slides in lands
# on the banner. Specs clicking near the bottom dismiss it first, as a visitor would.
module CookieBannerHelpers
  def dismiss_cookie_banner
    click_button I18n.t('cookies.accept')
    expect(page).to have_no_button(I18n.t('cookies.accept'))
  end
end

RSpec.configure { |config| config.include CookieBannerHelpers, type: :system }
