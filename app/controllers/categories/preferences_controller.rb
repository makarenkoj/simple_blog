module Categories
  class PreferencesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_category

    def create
      begin
        current_user.preferred_categories << @category unless current_user.preferred_categories.exists?(@category.id)
        current_user.preferred_categories.reload
        flash.now[:notice] = t('activerecord.attributes.categories.preferences.subscribed', category: @category.name)
      rescue StandardError
        flash.now[:alert] = t('activerecord.attributes.categories.preferences.error.subscribe', category: @category.name)
      end

      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.turbo_stream
      end
    end

    def destroy
      begin
        current_user.preferred_categories.delete(@category)
        current_user.preferred_categories.reload
        flash.now[:notice] = t('activerecord.attributes.categories.preferences.unsubscribed', category: @category.name)
      rescue StandardError
        flash.now[:alert] = t('activerecord.attributes.categories.preferences.error.unsubscribe', category: @category.name)
      end

      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.turbo_stream
      end
    end

    private

    def set_category
      @category = Category.find_by(name: params[:category_id])
      return if @category

      message = t('activerecord.controllers.categories.not_found', default: 'Категорію не знайдено')
      respond_to do |format|
        format.html do
          redirect_back fallback_location: categories_path, alert: message
        end

        format.turbo_stream do
          flash.now[:alert] = message
          render turbo_stream: turbo_stream.prepend('flash_messages', partial: 'partials/flash_message', locals: { type: :alert, message: message }), status: :not_found
        end
      end
    end
  end
end
