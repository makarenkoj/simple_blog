module Posts
  class FormComponent < RubyUI::Base
    def initialize(post:)
      @post = post
    end

    def view_template
      form_with model: @post, wrapper: :vertical_multi_select do |f|
        render Partials::FormErrorsComponent.new(model: @post)

        div(class: 'form-group') { f.input :title }
        div(class: 'form-group') { f.input :body, as: :text, input_html: { rows: 23, cols: 150 } }

        div(class: 'actions') do
          f.button :submit, t('activerecord.post.save'), class: 'btn btn-primary'
          text t('activerecord.post.or')
          link_to t('activerecord.post.back'), :back, class: 'btn btn-primary'
        end
      end
    end
  end
end
