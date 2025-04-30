module Posts
  class IndexView < ApplicationLayout
    attr_reader :posts

    def initialize(posts:, view_context: nil)
      super(view_context: view_context)
      @posts = posts
    end

    def view_template
      super do
        div(class: 'post-heading') do
          div(class: 'subheading') do
            @posts&.each do |post|
              render Posts::PostComponent.new(post: post, view_context: @view_context)
            end
          end
        end
      end
    end
  end
end
