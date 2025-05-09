module Users
  class ShowView < ApplicationLayout
    attr_reader :user

    def initialize(user:, view_context: nil)
      super(view_context: view_context)
      @user = user
    end

    def view_template
      super do
        div(class: 'event') do
          div(class: 'flex flex-wrap') do
            div(class: 'w-full') do
              div(class: 'flex flex-wrap') do
                div(class: 'w-full') do
                  div(class: 'event-description mb-4') { p(class: 'text-gray-700') { @user.email } }
                  div(class: 'my-4') do
                    buttons_block if view_context.current_user == @user
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
        div(class: 'basis-24 bg-blue-500 text-white font-bold py-2 px-4 rounded hover:bg-blue-700 mr-4') do
          edit_user
        end

        div(class: 'basis-24 bg-red-500 text-white font-bold py-2 px-4 rounded hover:bg-red-700') do
          delete_user
        end
      end
    end

    def delete_user
      button_to t('activerecord.user.destroy'),
                view_context.user_path(@user),
                method: :delete,
                form: { data: { turbo_confirm: t('activerecord.user.destroy_confirm') } }
    end

    def edit_user
      link_to t('activerecord.user.change'),
              view_context.edit_user_path(@user)
    end
  end
end
