# A user liked a post as often as they posted the like request: every repeat stored
# another row and notified the author again. The unique index makes one like per user
# and post a database fact (production had no duplicates on 2026-11-17, so it applies
# cleanly). It starts with user_id, so the single-column user_id index is redundant.
class MakeLikesUniquePerUserAndPost < ActiveRecord::Migration[8.1]
  def change
    add_index :likes, %i[user_id post_id], unique: true
    remove_index :likes, :user_id, name: 'index_likes_on_user_id'
  end
end
