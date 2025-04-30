class ApplicationLayout < RubyUI::Base
  include Phlex::Rails::Layout

  def initialize(view_context: nil, **args)
    super(view_context: view_context, **args)
  end

  def view_template(&block)
    doctype
    html(lang: 'ua') do
      head_section
      body do
        render Navbar.new(view_context: @view_context)
        render Container.new(view_context: @view_context, &block)
        render Footer.new(view_context: @view_context)
      end
    end
  end

  private

  def head_section
    head do
      meta charset: 'utf-8'
      meta "http-equiv": 'X-UA-Compatible', content: 'IE=Edge,chrome=1'
      meta name: 'viewport', content: 'width=device-width, initial-scale=1.0'
      title { content_for?(:title) ? yield(:title) : 'SimpleBlog' }
      csrf_meta_tags
      view_context.stylesheet_link_tag 'application', media: 'all', "data-turbo-track": 'reload'
    end
  end
end
