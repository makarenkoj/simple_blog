module Posts
  class UpdateFormComponent < RubyUI::Base
    attr_reader :post

    def initialize(post:, view_context:)
      super(view_context: view_context)
      @post = post
    end

    def view_template
      view_context.simple_form_for(@post, url: new_post_path) do |f|
        render ::Partials::FormErrorsComponent.new(model: @post)

        div(class: 'form-group mb-4') do
          f.input :title, label: t('activerecord.attributes.post.title'),
                          input_html: { class: 'form-input w-full', placeholder: t('simple_form.edit_form.post.body.placeholder') }
        end

        div(class: 'form-group mb-4') do
          f.rich_text_area :body, label: t('activerecord.attributes.post.body'),
                                  class: 'trix-content prose prose-lg',
                                  placeholder: @post.body.presence || t('simple_form.edit_form.post.body.placeholder')
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
