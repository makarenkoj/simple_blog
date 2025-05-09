class Navbar < RubyUI::Base
  TARGET_ID = 'navbarNav'.freeze

  def view_template
    nav(class: 'bg-gray-800 text-white p-4 shadow-md') do
      div(class: 'container mx-auto flex items-center justify-between') do
        logo
        toggle_button
        menu_links
        locale_switcher
      end
    end
  end

  private

  def toggle_button
    button class: 'block lg:hidden px-3 py-2 rounded text-gray-200 hover:text-white focus:outline-none focus:ring-2 focus:ring-white', type: 'button',
           data: { toggle: 'collapse', target: "##{TARGET_ID}" },
           aria: { controls: TARGET_ID, expanded: 'false', label: 'Toggle navigation' } do
      span(class: 'sr-only') { 'Toggle navigation' }
      span(class: 'block w-6 h-px bg-white mb-1')
      span(class: 'block w-6 h-px bg-white mb-1')
      span(class: 'block w-6 h-px bg-white')
    end
  end

  def menu_links
    div(class: 'hidden w-full lg:flex lg:items-center lg:w-auto', id: TARGET_ID) do
      ul(class: 'flex flex-col lg:flex-row lg:space-x-8 mt-4 lg:mt-0 lg:ml-4') do
        if user_signed_in?
          signed_in_links
        else
          signed_out_links
        end
      end
    end
  end

  def signed_in_links
    nav_item t('activerecord.post.create'), new_post_path
    nav_item current_user.email, current_user
    nav_item t('activerecord.attributes.user.sign_out'), destroy_user_session_path, method: :delete
  end

  def signed_out_links
    nav_item t('activerecord.attributes.user.sign_in'), new_user_session_path
    nav_item t('activerecord.attributes.user.sign_up'), new_user_registration_path
  end

  def nav_item(text, path, method: nil)
    li do
      link_to text, path, class: 'bg-gray-700 text-white font-bold py-2 px-4 rounded hover:bg-gray-600', method: method
    end
  end

  def emoji_flag(country_code)
    view_context.emoji_flag(country_code)
  end

  def locale_switcher
    div(class: 'hidden w-full lg:flex lg:items-center lg:w-auto', id: 'navbarNav') do
      ul(class: 'flex flex-col lg:flex-row space-x-2 mt-2 lg:mt-2') do
        nav_item emoji_flag('gb'), root_path(locale: :en)
        nav_item emoji_flag('ua'), root_path(locale: :uk)
      end
    end
  end

  def root_logo(text, path, method: nil)
    li do
      link_to text, path, class: 'text-lg font-bold', method: method
    end
  end

  def logo
    div(class: 'hidden w-full lg:flex lg:items-center lg:w-auto', id: 'navbarNav') do
      ul(class: 'flex flex-col lg:flex-row lg:space-x-8 mt-4 lg:mt-0 lg:ml-4') do
        root_logo t('activerecord.app.name'), root_path
      end
    end
  end
end
