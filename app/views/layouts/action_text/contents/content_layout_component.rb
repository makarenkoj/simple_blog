module ActionText
  class ContentLayoutComponent < RubyUI::Base
    def initialize(view_context: nil)
      super(view_context: view_context) if view_context
    end

    def template(&block)
      div(class: 'trix-content') do
        yield_content(&block)
      end
    end
  end
end
