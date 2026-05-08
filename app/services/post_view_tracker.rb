class PostViewTracker
  COOLDOWN_PERIOD = 1.hour

  def initialize(post, request, current_user)
    @post = post
    @request = request
    @current_user = current_user
  end

  def track
    return if @current_user == @post.user

    cache_key = "post_view:#{@post.id}:#{@request.remote_ip}"

    return if Rails.cache.exist?(cache_key)

    Rails.cache.write(cache_key, true, expires_in: COOLDOWN_PERIOD)
    TrackPostViewJob.perform_later(@post.id, @current_user&.id, @request.remote_ip)
  end
end
