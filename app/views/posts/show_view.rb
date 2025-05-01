module Posts
  class ShowView < ApplicationLayout
    attr_reader :post

    def initialize(post:, view_context: nil)
      super(view_context: view_context)
      @post = post
    end

    def view_template
      super do
        div(class: 'event') do
          div(class: 'flex flex-wrap') do
            div(class: 'w-full') do
              div(class: 'flex flex-wrap') do
                div(class: 'w-full') do
                  div(class: 'event-description mb-4') { h1(class: 'text-2xl font-bold') { @post.title } }
                  div(class: 'event-description mb-4') { p(class: 'text-gray-700') { @post.body } }
                  div(class: 'my-4') do
                    buttons_block if view_context.current_user_can_edit?(@post)
                  end
                end
              end
            end
          end
        end
      end
    end

    private

    def buttons_block
      div(class: 'flex flex-row') do
        div(class: 'basis-24') do
          edit_post
        end

        div(class: 'basis-24') do
          delete_post
        end
      end
    end

    def delete_post
      button_to t('activerecord.post.destroy'),
                view_context.post_path(@post),
                method: :delete,
                form: { data: { turbo_confirm: t('activerecord.post.destroy_confirm') } },
                class: 'bg-red-500 text-white font-bold py-2 px-4 rounded hover:bg-red-700'
    end

    def edit_post
      button_to t('activerecord.post.change'),
                view_context.edit_post_path(@post),
                class: 'bg-blue-500 text-white font-bold py-2 px-4 rounded hover:bg-blue-700 mr-4'
    end
  end
end
