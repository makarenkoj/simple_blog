module Partials
  class FormErrorsComponent < RubyUI::Base
    def initialize(model:)
      @model = model
    end

    def view_template
      return unless @model.errors.any?

      div(class: 'form-errors') do
        ul do
          @model.errors.full_messages.each do |msg|
            li { msg }
          end
        end
      end
    end
  end
end
