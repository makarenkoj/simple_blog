class CreatePostViews < ActiveRecord::Migration[8.0]
  def change
    create_table :post_views do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :ip_address

      t.timestamps
    end

    add_index :post_views, [:post_id, :ip_address, :created_at]
  end
end
