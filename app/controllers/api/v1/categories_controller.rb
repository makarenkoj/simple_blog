module Api
  module V1
    class CategoriesController < BaseController
      def index
        @categories = Category.all

        render json: @categories.as_json(only: %i[id name])
      end
    end
  end
end
