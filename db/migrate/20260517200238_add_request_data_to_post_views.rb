class AddRequestDataToPostViews < ActiveRecord::Migration[8.0]
  def change
    add_column :post_views, :request_data, :jsonb, default: {}, null: false
    add_index :post_views, :request_data, using: :gin
  end
end
