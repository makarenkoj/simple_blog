class ApplicationLayout < RubyUI::Base
  include Phlex::Rails::Layout

  def initialize(view_context: nil, **args)
    super(view_context: view_context, **args)
  end

  def view_template(&block) # rubocop:disable Metrics/AbcSize
    doctype
    html(lang: 'ua') do
      head_section
      body(class: 'flex flex-col min-h-screen') do
        render Navbar.new(view_context: @view_context)
        div(class: 'content flex-grow') do
          div(class: 'container mx-auto mt-4 px-4 py-3 bg-green-100 border border-green-400 text-green-700 rounded') { view_context.flash[:notice] } if view_context.flash[:notice]
          div(class: 'container mx-auto mt-4 px-4 py-3 bg-yellow-100 border border-yellow-400 text-yellow-700 rounded') { view_context.flash[:alert] } if view_context.flash[:alert]
          div(class: 'container mx-auto mt-4 px-4 py-3 bg-red-100 border border-red-400 text-red-700 rounded') { view_context.flash[:error] } if view_context.flash[:error]
          render Container.new(view_context: @view_context, &block)
        end

        render Footer.new(view_context: @view_context)
        # unsafe_raw view_context.javascript_importmap_tags
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
      unsafe_raw csrf_meta_tags
      unsafe_raw csp_meta_tag
      unsafe_raw view_context.javascript_importmap_tags
      unsafe_raw view_context.stylesheet_link_tag 'application', media: 'all', "data-turbo-track": 'reload'
    end
  end
end
