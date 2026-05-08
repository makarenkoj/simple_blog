require 'rails_helper'

RSpec.describe PostViewTracker do
  let(:author) { create(:user) }
  let(:viewer) { create(:user) }
  let(:post) { create(:post, user: author) }
  
  let(:request) { double('request', remote_ip: '127.0.0.1') }
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
        expect(Rails.cache.exist?(cache_key)).to be_falsey
      end
    end

    context 'when a regular user or guest views the post' do
      let(:tracker) { described_class.new(post, request, viewer) }

      it 'enqueues a TrackPostViewJob' do
        expect { tracker.track }.to have_enqueued_job(TrackPostViewJob).with(post.id, viewer.id, request.remote_ip)
      end

      it 'writes to the cache to prevent duplicate counting' do
        tracker.track

        cache_key = "post_view:#{post.id}:#{request.remote_ip}"
        expect(Rails.cache.exist?(cache_key)).to be_truthy
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
  end
end
