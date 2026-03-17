class FcmService
  def self.send_notification(notification)
    user = notification.user
    token = user.fcm_token

    return if token.blank?

    base64_creds = ENV['FIREBASE_CREDENTIALS_BASE64']

    if base64_creds.blank?
      Rails.logger.error 'FCM Error: FIREBASE_CREDENTIALS_BASE64 is missing in .env'
      return
    end

    temp_file = Tempfile.new('firebase_creds')

    begin
      decoded_json = Base64.decode64(base64_creds)
      temp_file.write(decoded_json)
      temp_file.close
      parsed_json = JSON.parse(decoded_json)
      project_id = parsed_json['project_id']
      fcm = FCM.new(temp_file.path, project_id)

      payload = {
        token: token,
        notification: {
          title: 'HelpBooost',
          body: notification.message
        }
      }

      response = fcm.send_v1(payload)
      Rails.logger.info "FCM Response: #{response}"
    ensure
      temp_file&.unlink
    end
  end
end
