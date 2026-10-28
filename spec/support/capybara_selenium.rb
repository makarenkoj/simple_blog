# Recent Chrome versions report a node from a document that is being replaced (e.g. right after
# a form submit reloads the page) as "unknown error: Node with given id does not belong to the
# document" instead of a StaleElementReferenceError. Capybara only retries on the errors listed
# in invalid_element_errors, so let it retry this one too instead of failing the spec at once.
module CapybaraRetryDetachedNodes
  def invalid_element_errors
    super + [Selenium::WebDriver::Error::UnknownError]
  end
end

Capybara::Selenium::Driver.prepend(CapybaraRetryDetachedNodes)
