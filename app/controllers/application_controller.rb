class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_user_can_edit?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: %i[password password_confirmation current_password]
    )
  end

  def current_user_can_edit?(model)
    user_signed_in? && (
    model.user == current_user ||
        (model.try(:post).present? && model.post.user == current_user)
  )
  end

  private

  def popular_categories
    scope = Category.left_joins(:posts)

    if user_signed_in?
      scope = scope.where.not(id: current_user.category_preferences.select(:category_id))
    end

    @categories = scope.group('categories.id')
                        .order('COUNT(posts.id) DESC')
                        .limit(5)
  end

    def popular_creators
    scope = User.creator.left_joins(:followers)

    if user_signed_in?
      scope = scope.where.not(id: current_user.followings.select(:id)).where.not(id: current_user.id)
    end

    @creators = scope.group('users.id')
                     .order('COUNT(follows.id) DESC')
                     .limit(5)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    parsed_locale = params[:locale]
    return unless I18n.available_locales.map(&:to_s).include?(parsed_locale)

    parsed_locale.to_sym
  end
end
