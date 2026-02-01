module Categories
  class PreferencesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_category

    def create
      unless current_user.preferred_categories.include?(@category)
        current_user.preferred_categories << @category
      end

      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.turbo_stream
      end
    end

    def destroy
      current_user.preferred_categories.delete(@category)

      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.turbo_stream
      end
    end

    private

    def set_category
      @category = Category.find_by(name: params[:category_id])
      redirect_back fallback_location: posts_path, alert: t('activerecord.controllers.categories.not_found') unless @category
    end
  end
end
