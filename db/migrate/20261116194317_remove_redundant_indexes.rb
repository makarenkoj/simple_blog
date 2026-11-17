# The single-column indexes are prefixes of composite indexes that serve the same
# lookups; the GIN index on post_views.request_data backs no query (it is only shown
# in the admin) and taxed every tracked view's insert. Reversible: down re-creates them.
class RemoveRedundantIndexes < ActiveRecord::Migration[8.0]
  def change
    remove_index :bookmarks, :user_id, name: 'index_bookmarks_on_user_id'
    remove_index :follows, :follower_id, name: 'index_follows_on_follower_id'
    remove_index :notifications, :user_id, name: 'index_notifications_on_user_id'
    remove_index :post_views, :post_id, name: 'index_post_views_on_post_id'
    remove_index :post_views, :request_data, name: 'index_post_views_on_request_data', using: :gin
  end
end
