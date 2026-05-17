class PostViewTracker
  COOLDOWN_PERIOD = 1.hour
  BOT_REGEX = /bot|spider|crawler|slurp|scraper|crawling|ahrefs|semrush|petalbot/i

  def initialize(post, request, current_user)
    @post = post
    @request = request
    @current_user = current_user
  end

  def track
    return if @current_user == @post.user
    return if bot_request?

    cache_key = "post_view:#{@post.id}:#{@request.remote_ip}"

    return if Rails.cache.exist?(cache_key)

    Rails.cache.write(cache_key, true, expires_in: COOLDOWN_PERIOD)
    extracted_data = extract_request_data
    TrackPostViewJob.perform_later(@post.id, @current_user&.id, @request.remote_ip, extracted_data)
  end

  private

  def bot_request?
    user_agent = @request.user_agent
    return true if user_agent.blank?

    user_agent.match?(BOT_REGEX)
  end

  def extract_request_data
    {
      referer: @request.referer,
      user_agent: @request.user_agent,
      device_type: @request.user_agent&.match?(/Mobile|Android|iPhone/i) ? 'mobile' : 'desktop',
      utm_source: @request.query_parameters[:utm_source],
      utm_medium: @request.query_parameters[:utm_medium],
      utm_campaign: @request.query_parameters[:utm_campaign]
    }.compact
  end
end
