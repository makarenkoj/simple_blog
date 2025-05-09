module Posts
  class EditView < ApplicationLayout
    attr_reader :post

    def initialize(post:, view_context: nil)
      super(view_context: view_context)
      @post = post
    end

    def view_template
      super do
        h1 { t('activerecord.controllers.posts.changed') }

        div(class: 'row') do
          div(class: 'col-md-6 buffer-top') do
            render Posts::UpdateFormComponent.new(post: @post, view_context: @view_context)
          end
        end
      end
    end
  end
end
