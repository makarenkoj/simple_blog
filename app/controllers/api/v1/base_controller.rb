module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate_api_user!

      private

      def authenticate_api_user!
        authenticate_or_request_with_http_token do |token, _options|
          user = User.find_by(api_token: token)

          if user && (user.api_token_expires_at.nil? || user.api_token_expires_at > Time.current)
            @current_user = user
          else
            false
          end
        end
      end

      attr_reader :current_user
    end
  end
end
