module Avo
  module Resources
    class Category < Avo::BaseResource
      # self.includes = []
      # self.attachments = []
      self.search = {
        query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: 'or').result(distinct: false) }
      }

      self.find_record_method = -> { query.find_by!(name: params[:id]) }

      def fields
        field :id, as: :id
        field :name, as: :text
        field :cover_image, as: :file
        field :categorizations, as: :has_many
        field :posts, as: :has_many, through: :categorizations
        field :category_preferences, as: :has_many
        field :users, as: :has_many, through: :category_preferences
      end
    end
  end
end
