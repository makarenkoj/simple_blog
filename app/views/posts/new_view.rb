module Posts
  class NewView < ApplicationLayout
    attr_reader :post

    def initialize(post:, view_context: nil)
      super(view_context: view_context)
      @post = post
    end

    def view_template
      super do
        h1 { t('activerecord.post.new') }

        div(class: 'row') do
          div(class: 'col-md-6 buffer-top') do
            render Posts::FormComponent.new(post: @post, view_context: view_context)
          end
        end
      end
    end
  end
end
