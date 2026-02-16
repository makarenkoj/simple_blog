Rails.application.configure do
  MissionControl::Jobs.base_controller_class = "::ApplicationController"
end

Rails.application.config.to_prepare do
  MissionControl::Jobs::ApplicationController.class_eval do
    skip_before_action :authenticate_by_http_basic, raise: false
  end
end
