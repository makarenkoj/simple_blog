# Runs the block in a browser window of the given size and restores the previous size, so a
# desktop- or mobile-only layout check does not leak its window into later system specs.
module WindowSizeHelpers
  def with_window_size(width, height)
    window = page.driver.browser.manage.window
    original = window.size
    window.resize_to(width, height)
    yield
  ensure
    window&.resize_to(original.width, original.height) if original
  end
end

RSpec.configure { |config| config.include WindowSizeHelpers, type: :system }
