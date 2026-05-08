module Avo
  module Resources
    class PostView < Avo::BaseResource
      # self.includes = []
      # self.attachments = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
      # }

      def fields
        field :id, as: :id
        field :post, as: :belongs_to
        field :user, as: :belongs_to
        field :ip_address, as: :text
      end
    end
  end
end
