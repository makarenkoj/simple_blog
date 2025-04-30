module Posts
  class PostComponent < RubyUI::Base
    attr_reader :post

    def initialize(post:, view_context:)
      super(view_context: view_context)
      @post = post
    end

    def view_template
      h1 do
        a(class: 'font-weight-light text-dark', href: post_path(@post)) { @post.title }
      end
    end
  end
end
