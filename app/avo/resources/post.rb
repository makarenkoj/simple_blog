module Avo
  module Resources
    class Post < Avo::BaseResource
      self.includes = [:user, { cover_image_attachment: :blob }]
      self.title = :title
      self.search = { query: -> { query.ransack(id_eq: params[:q], title_cont: params[:q], m: 'or').result(distinct: false) } }

      def fields
        field :id, as: :id
        field :title, as: :text, required: true
        field :cover_image, as: :file, is_image: true
        field :body_html, as: :code, language: 'xml', always_show: true
        field :user_id, as: :number
        field :user, as: :belongs_to, searchable: true
        field :status, as: :select, enum: ::Post.statuses
        field :views_count, as: :number
        field :categories, as: :has_many, through: :categorizations
        field :bookmarks, as: :has_many
        field :likes, as: :has_many
        field :liking_users, as: :has_many, through: :likes
      end
    end
  end
end
