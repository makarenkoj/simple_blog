require 'rails_helper'

RSpec.describe ApiTokenService do
  include_context 'base'

  describe '.generate!' do
    context 'without expiration time' do
      it 'generate token without expiration time' do
        expect { described_class.generate!(current_user) }.to change { current_user.reload.api_token }.from(nil)

        expect(current_user.api_token_expires_at).to be_nil
        expect(current_user.api_token.length).to be > 20
      end
    end

    context 'with expiration time' do
      it 'install the expiration time' do
        freeze_time do
          described_class.generate!(current_user, expires_in: 1.week)

          expect(current_user.reload.api_token).to be_present
          expect(current_user.api_token_expires_at).to eq(1.week.from_now)
        end
      end
    end
  end

  describe '.revoke!' do
    before do
      described_class.generate!(current_user, expires_in: 1.month)
    end

    it 'clears the API token and expiration time' do
      expect(current_user.api_token).to be_present

      described_class.revoke!(current_user)

      expect(current_user.reload.api_token).to be_nil
      expect(current_user.api_token_expires_at).to be_nil
    end
  end
end
