# Fan-out of a published post to the author's followers. Runs in the background so
# publishing does not wait on one insert, three broadcasts and a push per follower.
class NotifyFollowersJob < ApplicationJob
  queue_as :default

  def perform(post)
    post.user.followers.find_each do |follower|
      Notification.create!(user: follower, actor: post.user, notifiable: post, action: Notification::ACTIONS[:new_post])
    end
  end
end
