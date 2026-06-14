module Avo
  module Resources
    class Like < Avo::BaseResource
      self.title = :id
      self.includes = %i[user post]

      def fields
        field :id, as: :id
        field :user, as: :belongs_to
        field :post, as: :belongs_to
        field :created_at, as: :date_time
      end
    end
  end
end
