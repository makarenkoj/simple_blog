class TrackPostViewJob < ApplicationJob
  queue_as :low_priority

  def perform(post_id, user_id, ip_address)
    post = Post.find_by(id: post_id)
    return unless post

    PostView.create!(post: post, user_id: user_id, ip_address: ip_address)
    Post.increment_counter(:views_count, post.id) # rubocop:disable Rails/SkipsModelValidations
  end
end
