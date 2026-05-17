require 'rails_helper'

RSpec.describe PostViewTracker do
  let(:author) { create(:user) }
  let(:viewer) { create(:user) }
  let(:post) { create(:post, user: author) }

  let(:request) do
    instance_double(
      ActionDispatch::Request,
      remote_ip: '127.0.0.1',
      user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      referer: 'https://example.com',
      query_parameters: {}
    )
  end

  let(:expected_request_data) do
    {
      referer: 'https://example.com',
      user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      device_type: 'desktop'
    }
  end

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe '#track' do
    context 'when an author views their own post' do
      let(:tracker) { described_class.new(post, request, author) }

      it 'does not enqueue a job' do
        expect { tracker.track }.not_to have_enqueued_job(TrackPostViewJob)
      end

      it 'does not write to cache' do
        tracker.track
        cache_key = "post_view:#{post.id}:#{request.remote_ip}"
        expect(Rails.cache).not_to exist(cache_key)
      end
    end

    context 'when a regular user or guest views the post' do
      let(:tracker) { described_class.new(post, request, viewer) }

      it 'enqueues a TrackPostViewJob' do
        expect { tracker.track }.to have_enqueued_job(TrackPostViewJob).with(post.id, viewer.id, request.remote_ip, expected_request_data)
      end

      it 'writes to the cache to prevent duplicate counting' do
        tracker.track

        cache_key = "post_view:#{post.id}:#{request.remote_ip}"
        expect(Rails.cache).to exist(cache_key)
      end
    end

    context 'when the same IP views the post multiple times within the cooldown period' do
      let(:tracker) { described_class.new(post, request, viewer) }

      it 'enqueues the job only once' do
        expect { tracker.track }.to have_enqueued_job(TrackPostViewJob).exactly(:once)
        expect { tracker.track }.not_to have_enqueued_job(TrackPostViewJob)
      end
    end

    context 'when the cooldown period has expired' do
      let(:tracker) { described_class.new(post, request, viewer) }

      it 'enqueues the job again' do
        tracker.track

        travel 61.minutes do
          expect { tracker.track }.to have_enqueued_job(TrackPostViewJob)
        end
      end
    end

    context 'when the request is from a bot' do
      let(:bot_request) do
        instance_double(
          ActionDispatch::Request,
          remote_ip: '127.0.0.1',
          user_agent: 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
          referer: nil,
          query_parameters: {}
        )
      end

      let(:tracker) { described_class.new(post, bot_request, viewer) }

      it 'does not enqueue a job' do
        expect { tracker.track }.not_to have_enqueued_job(TrackPostViewJob)
      end

      it 'does not write to cache' do
        tracker.track
        cache_key = "post_view:#{post.id}:#{bot_request.remote_ip}"
        expect(Rails.cache).not_to exist(cache_key)
      end
    end
  end
end
