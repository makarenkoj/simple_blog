module Posts
  class NewView < ApplicationLayout
    def view_template
      super do
        h1 { t('activerecord.post.new') }

        div(class: 'row') do
          div(class: 'col-md-6 buffer-top') do
            render Posts::FormComponent.new(post: @post)
          end
        end
      end
    end
  end
end
