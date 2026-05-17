require 'rails_helper'

RSpec.describe TrackPostViewJob, type: :job do
  include_context 'base'

  let(:post) { create(:post) }
  let(:ip_address) { '192.168.1.1' }
  let(:request_data) do
    {
      'referer' => 'https://google.com',
      'user_agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      'device_type' => 'desktop'
    }
  end

  describe '#perform' do
    it 'creates a PostView record with all data including request_data' do
      expect { described_class.perform_now(post.id, current_user.id, ip_address, request_data) }.to change(PostView, :count).by(1)

      post_view = PostView.last
      expect(post_view.post_id).to eq(post.id)
      expect(post_view.user_id).to eq(current_user.id)
      expect(post_view.ip_address).to eq(ip_address)
      expect(post_view.request_data).to eq(request_data)
    end

    it 'works correctly when request_data is omitted (defaults to empty hash)' do
      expect { described_class.perform_now(post.id, current_user.id, ip_address) }.to change(PostView, :count).by(1)

      expect(PostView.last.request_data).to eq({})
    end

    it 'increments the posts views_count' do
      expect { described_class.perform_now(post.id, current_user.id, ip_address, request_data) }.to change { post.reload.views_count }.by(1)
    end

    it 'does nothing if the post does not exist' do
      expect { described_class.perform_now(-1, current_user.id, ip_address, request_data) }.not_to change(PostView, :count)
    end

    it 'works for guest users (user_id is nil)' do
      expect { described_class.perform_now(post.id, nil, ip_address, request_data) }.to change(PostView, :count).by(1)

      expect(PostView.last.user_id).to be_nil
    end
  end
end
