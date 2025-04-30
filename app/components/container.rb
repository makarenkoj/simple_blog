class Container < RubyUI::Base
  def view_template
    div(class: 'container mx-auto py-8') do
      div(class: 'flex flex-wrap justify-center') do
        div(class: 'w-full lg:w-8/12 md:w-10/12 mx-auto') do
          if view_context.flash[:notice]
            p(id: 'notice',
              class: 'bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4') do
              view_context.flash[:notice]
            end
          end
          if view_context.flash[:alert]
            p(id: 'alert',
              class: 'bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded relative mb-4') do
              view_context.flash[:alert]
            end
          end
          if view_context.flash[:error]
            p(id: 'error', class: 'bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4') do
              view_context.flash[:error]
            end
          end

          yield # Рендерить вміст, переданий з ApplicationLayout
        end
      end
    end
  end
end
