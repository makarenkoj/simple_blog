module Posts
  class EditView < ApplicationLayout
    def view_template
      h1 { t('activerecord.controllers.posts.changed') }

      div(class: 'row') do
        div(class: 'col-md-6 buffer-top') do
          render Posts::FormComponent.new(post: @post)
        end
      end
    end
  end
end
