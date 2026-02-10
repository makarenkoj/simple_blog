module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters

    def create
      super do |resource|
        render :new, status: :unprocessable_entity and return if resource.errors.any?
      end
    end

    def update
      super do |resource|
        render :edit, status: :unprocessable_entity and return if resource.errors.any?
      end
    end

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :username, :role, :avatar, { preferred_category_ids: [] }])
      devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :username, :role, :avatar, { preferred_category_ids: [] }])
    end

    def after_sign_up_path_for(_resource)
      root_path
    end

    def after_update_path_for(resource)
      user_path(resource)
    end
  end
end
