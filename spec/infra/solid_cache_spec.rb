require 'rails_helper'

# Production caches in the `cache` database through Solid Cache (config/cache.yml), so cached
# state - post-view cooldowns, search rate-limit counters - outlives a container. A store built
# afresh stands in for the new container a deploy starts.
RSpec.describe 'Solid Cache store', type: :model do
  def fresh_store = ActiveSupport::Cache.lookup_store(:solid_cache_store)

  after { fresh_store.clear }

  it 'keeps a value written by one store instance for the next one' do
    fresh_store.write('post_view:42:203.0.113.7', true, expires_in: 1.hour)

    expect(fresh_store.read('post_view:42:203.0.113.7')).to be(true)
  end

  it 'counts across instances, as rate limits need' do
    3.times { fresh_store.increment('rate-limit:search:203.0.113.7', 1, expires_in: 1.minute) }

    expect(fresh_store.read('rate-limit:search:203.0.113.7', raw: true).to_i).to eq(3)
  end

  it 'stores entries in the cache database, not the primary one' do
    fresh_store.write('where-am-i', 'cache db')

    expect(SolidCache::Entry.connection_db_config.name).to eq('cache')
    expect(SolidCache::Entry.count).to be >= 1
  end
end
