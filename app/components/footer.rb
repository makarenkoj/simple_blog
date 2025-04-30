class Footer < RubyUI::Base
  def view_template
    footer(class: 'footer bg-gray-800 text-white py-4') do
      div(class: 'container mx-auto text-center') do
        p(class: 'text-center text-sm') do
          safe_join(["© #{t('activerecord.app.company')} #{l Time.zone.now, format: :year}".html_safe])
        end
        link_to t('activerecord.app.url'), 'https://blogasik.herokuapp.com/', class: 'text-blue-200 hover:underline text-sm'
      end
    end
  end
end
