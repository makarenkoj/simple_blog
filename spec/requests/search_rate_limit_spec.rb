require 'rails_helper'

# /search is public and each request runs ILIKE scans over posts, users and categories,
# so it is rate limited per IP: live search (a turbo frame per pause in typing) and the
# full results page have separate budgets.
RSpec.describe 'Search rate limit', type: :request do
  let(:frame_headers) { { 'Turbo-Frame' => 'search_results' } }

  before { Rails.configuration.x.rate_limit_store.clear }

  def search(headers: {}, ip: '203.0.113.7')
    get search_path, params: { query: 'ruby' }, headers: headers.merge('REMOTE_ADDR' => ip)
    response
  end

  it 'answers 429 once the full-page budget is spent' do
    statuses = Array.new(SearchController::PAGE_LIMIT) { search.status }

    expect(statuses.uniq).to eq([200])
    expect(search).to have_http_status(:too_many_requests)
    expect(response.body).to include(I18n.t('search.rate_limited'))
  end

  it 'answers live search with a 429 inside its turbo frame once that budget is spent' do
    SearchController::FRAME_LIMIT.times { search(headers: frame_headers) }

    expect(search(headers: frame_headers)).to have_http_status(:too_many_requests)
    expect(response.body).to include('<turbo-frame id="search_results">', I18n.t('search.rate_limited'))
  end

  it 'keeps live search working while typing after the full-page budget is spent' do
    (SearchController::PAGE_LIMIT + 1).times { search }

    # Typing "ruby on rails" with the 300 ms debounce sends at most one request per letter.
    statuses = Array.new('ruby on rails'.length) { search(headers: frame_headers).status }
    expect(statuses.uniq).to eq([200])
  end

  it 'counts each IP separately' do
    (SearchController::PAGE_LIMIT + 1).times { search(ip: '203.0.113.7') }

    expect(search(ip: '198.51.100.9')).to have_http_status(:ok)
  end
end
