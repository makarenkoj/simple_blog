class Avo::Resources::Like < Avo::BaseResource
  self.title = :id
  self.includes = [:user, :post]

  def fields
    field :id, as: :id
    field :user, as: :belongs_to
    field :post, as: :belongs_to
    field :created_at, as: :date_time
  end
end
