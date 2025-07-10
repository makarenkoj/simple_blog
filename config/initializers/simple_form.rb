# config/initializers/simple_form_tailwind.rb
# frozen_string_literal: true

# Use this setup method to configure Simple Form to work with Tailwind CSS.
# You can also add a `config/simple_form_tailwind.yml` file to
# customize the configuration.
SimpleForm.setup do |config|
  # Default class for input fields
  config.input_class = 'block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm'

  # Default class for labels
  config.label_class = 'block text-sm font-medium text-gray-700 mb-1'

  # Removed: config.hint_class and config.error_class from top level,
  # as they are not available in Simple Form 5.3.1 at this level.
  # They are defined within the wrappers.

  # Default wrapper for inputs
  config.wrappers :default, class: 'mb-4',
                            hint_class: 'mt-2 text-sm text-gray-500', # Defined here for default wrapper
                            error_class: 'mt-2 text-sm text-red-600' do |b| # Defined here for default wrapper
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :readonly
    b.use :label, class: 'block text-sm font-medium text-gray-700 mb-1'
    b.use :input, class: 'w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500'
    b.use :hint, wrap_with: { tag: :p, class: :hint }
    b.use :error, wrap_with: { tag: :span, class: :error }
  end

  # Wrapper for boolean inputs (checkboxes/radio buttons)
  config.wrappers :boolean, tag: 'div', class: 'flex items-center mt-2',
                            error_class: 'form-check-inline-error', # This class is for Simple Form internal use
                            hint_class: 'form-check-inline-hint' do |b| # This class is for Simple Form internal use
    b.use :html5
    b.optional :readonly
    b.wrapper :field_and_label, tag: 'div', class: 'flex items-center' do |ba|
      ba.use :input, class: 'h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500'
      ba.use :label, class: 'ml-2 block text-sm text-gray-900'
    end
    b.use :hint, wrap_with: { tag: :p, class: 'text-sm text-gray-500' } # Hint class for boolean
    b.use :error, wrap_with: { tag: :span, class: 'text-sm text-red-600' } # Error class for boolean
  end

  # Default configuration for submit buttons
  config.button_class = 'w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-base font-medium text-gray-900 bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500'

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :default

  # Define the way to render check boxes / radio buttons with labels.
  config.boolean_style = :nested

  # Default class for buttons (already defined above, this might be redundant if button_class is set globally)
  # config.button_class = 'btn' # Keep the one above for Tailwind classes

  # Other configurations (keep as is or adjust as needed)
  config.error_notification_tag = :div
  # config.error_notification_class = 'error_notification' # You might want to add Tailwind classes here too
  config.error_notification_class = 'rounded-lg p-4 text-sm bg-red-100 text-red-700 border border-red-400 mb-4'
  # config.error_notification_class = 'rounded-lg p-4 text-sm bg-red-100 text-red-700 border border-red-400'

  config.browser_validations = false

  # You can define the class to use on all labels. Default is nil.
  # config.label_class = nil # This is overridden by the label_class defined above

  # Define the default class of the input wrapper of the boolean input.
  config.boolean_label_class = 'checkbox' # This is more for Simple Form's internal structure
end
