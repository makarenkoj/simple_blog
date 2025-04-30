module Posts
  class ShowView < ApplicationLayout
    attr_reader :post

    def initialize(post:, view_context: nil)
      super(view_context: view_context)
      @post = post
    end

    def view_template
      div(class: 'event') do
        div(class: 'flex flex-wrap') do
          div(class: 'w-full') do
            div(class: 'flex flex-wrap') do
              div(class: 'w-full') do
                div(class: 'event-description mb-4') { h1(class: 'text-2xl font-bold') { @post.title } }
                div(class: 'event-description mb-4') { p(class: 'text-gray-700') { @post.body } }
                div(class: 'my-4') do
                  if view_context.current_user_can_edit?(@post)
                    link_to t('activerecord.post.change'), view_context.edit_post_path(@post),
                            class: 'bg-blue-500 text-white font-bold py-2 px-4 rounded hover:bg-blue-700 mr-4'
                    link_to t('activerecord.post.destroy'), view_context.post_path(@post), method: :delete,
                                                                                           data: { confirm: t('activerecord.post.destroy_confirm') },
                                                                                           class: 'bg-red-500 text-white font-bold py-2 px-4 rounded hover:bg-red-700'
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
