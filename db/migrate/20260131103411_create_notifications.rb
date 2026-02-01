class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.references :notifiable, polymorphic: true, null: false
      t.string :action, null: false
      t.boolean :read, default: false, null: false

      t.timestamps
    end

    add_index :notifications, [:user_id, :read]
    add_index :notifications, :created_at
  end
end
