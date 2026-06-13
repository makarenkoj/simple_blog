module Avo
  module Resources
    class PostView < Avo::BaseResource
      self.includes = %i[post user]

      def fields
        field :id, as: :id
        field :post, as: :belongs_to
        field :user, as: :belongs_to
        field :ip_address, as: :text
        field :request_data, as: :code, language: 'json', only_on: :show
        field :created_at, as: :date_time
      end
    end
  end
end
