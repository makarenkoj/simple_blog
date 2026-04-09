class AddStatusToPosts < ActiveRecord::Migration[8.0]
  def up
    add_column :posts, :status, :integer, default: 0, null: false
    execute("UPDATE posts SET status = 1")
  end

  def down
    remove_column :posts, :status
  end
end
