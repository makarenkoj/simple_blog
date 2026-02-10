module Avo
  module Resources
    class Post < Avo::BaseResource
      self.title = :title
      self.search = { query: -> { query.ransack(id_eq: params[:q], title_cont: params[:q], m: 'or').result(distinct: false) } }

      def fields
        field :id, as: :id
        field :title, as: :text, required: true
        field :body, as: :trix, always_show: true
        field :user_id, as: :number
        field :cover_image, as: :file, is_image: true
        field :user, as: :belongs_to, searchable: true
        field :categorizations, as: :has_many
        field :categories, as: :has_many, through: :categorizations
        field :bookmarks, as: :has_many
        field :likes, as: :has_many
        field :liking_users, as: :has_many, through: :likes
      end
    end
  end
end
