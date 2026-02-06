module Avo
  module Resources
    class User < Avo::BaseResource
      self.title = :username
      self.search = {
        query: -> { query.ransack(id_eq: params[:q], username_cont: params[:q], email_cont: params[:q], m: 'or').result(distinct: false) }
      }

      def fields
        field :id, as: :id
        field :avatar, as: :file, is_image: true, rounded: true
        field :username, as: :text
        field :email, as: :text
        field :first_name, as: :text
        field :last_name, as: :text
        field :password, as: :password,
                         name: 'Новий пароль',
                         only_on: :forms,
                         help: 'Залиште пустим, якщо не хочете змінювати'

        field :password_confirmation, as: :password,
                                      name: 'Підтвердження пароля',
                                      only_on: :forms

        field :role, as: :badge,
                     options: { info: 'reader', success: 'creator', warning: 'admin' },
                     only_on: %i[index show]

        field :role, as: :select,
                     enum: ::User.roles,
                     only_on: [:forms],
                     required: true

        tabs do
          tab 'Контент' do
            field :posts, as: :has_many
            field :preferred_categories, as: :has_many
          end

          tab 'Соціум' do
            field :followings, as: :has_many, use_resource: :user
            field :followers, as: :has_many, use_resource: :user
          end

          # tab "Активність" do
          #   field :bookmarked_posts, as: :has_many, use_resource: :post
          #   field :liked_posts, as: :has_many, use_resource: :post
          # end
        end
      end
    end
  end
end
