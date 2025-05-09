module Users
  class EditFormComponent < RubyUI::Base
    attr_reader :user

    def initialize(user:, view_context:)
      super(view_context: view_context)
      @user = user
    end

    def view_template
      view_context.simple_form_for @user, html: { multipart: true }, wrappers: :horizontal_multi_select do |f|
        # render ::Partials::FormErrorsComponent.new(model: @user)

        div(class: 'form-group mb-4') do
          f.input :email, label: t('activerecord.attributes.post.title'),
                          input_html: { class: 'form-input w-full', placeholder: t('simple_form.edit_form.post.body.placeholder') }
        end

        div(class: 'actions flex space-x-4') do
          div(class: 'actions flex-1') do
            f.submit t('activerecord.post.save'), class: 'bg-blue-500 text-white font-bold py-2 px-4 rounded hover:bg-blue-700'
          end

          div(class: 'flex-1') do
            if @post.persisted?
              link_to t('activerecord.post.back'), post_path(@post), class: 'bg-gray-500 text-white font-bold py-2 px-4 rounded hover:bg-gray-700'
            else
              link_to t('activerecord.post.back'), posts_path, class: 'bg-gray-500 text-white font-bold py-2 px-4 rounded hover:bg-gray-700'
            end
          end
        end
      end
    end
  end
end
