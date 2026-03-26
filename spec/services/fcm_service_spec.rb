require 'rails_helper'

RSpec.describe FcmService do
  let(:user) { create(:user, fcm_token: 'test_token_123') }
  let(:notification) { build(:notification, user: user) }
  let(:fake_fcm_client) { instance_double(FCM) }
  let(:valid_json) { { 'project_id': 'test-project-123' }.to_json }
  let(:valid_base64) { Base64.strict_encode64(valid_json) }

  describe '.send_notification' do
    context 'when the user does not have a token (fcm_token is empty)' do
      let(:user_without_token) { create(:user, fcm_token: nil) }
      let(:notification_without_token) { build(:notification, user: user_without_token) }

      it 'does not try to send a push notification and simply returns' do
        expect(FCM).not_to receive(:new)

        described_class.send_notification(notification_without_token)
      end
    end

    context 'when the environment variable FIREBASE_CREDENTIALS_BASE64 is missing in .env' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('FIREBASE_CREDENTIALS_BASE64').and_return(nil)
      end

      it 'logs the error and stops execution' do
        expect(Rails.logger).to receive(:error).with('FCM Error: FIREBASE_CREDENTIALS_BASE64 is missing in .env')
        expect(FCM).not_to receive(:new)

        described_class.send_notification(notification)
      end
    end

    context 'when everything is set up correctly and the token is present' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('FIREBASE_CREDENTIALS_BASE64').and_return(valid_base64)

        allow(FCM).to receive(:new).and_return(fake_fcm_client)
        allow(fake_fcm_client).to receive(:send_v1).and_return({ status: 200, body: 'success' })
      end

      it 'successfully forms the payload and calls the send_v1 method on FCM' do
        expected_payload = {
          token: 'test_token_123',
          notification: {
            title: 'HelpBooost',
            body: notification.message
          }
        }

        expect(fake_fcm_client).to receive(:send_v1).with(expected_payload)
        expect(Rails.logger).to receive(:info).with(/FCM Response:/)

        described_class.send_notification(notification)
      end
    end
  end
end
