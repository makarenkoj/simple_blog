# Posts are written in Tiptap and stored in posts.body_html; Action Text was removed from
# the code in SAM1-20. Production (2026-11-18): all 55 posts have body_html, the 44
# action_text_rich_texts rows are old copies, posts.body is empty everywhere.
#
# The 45 active_storage_attachments whose record is an ActionText::RichText stay on
# purpose: those blobs are the images old posts still show through <img> tags in
# body_html. Dropping the table with SQL runs no callbacks, so nothing purges them.
#
# Backup taken before this migration: pg_dump of action_text_rich_texts and
# active_storage_attachments (owner's ~/backups/simple_blog/2026-11-18_*.sql).
# `down` restores the structure only; restore rows from that backup.
class DropActionTextLeftovers < ActiveRecord::Migration[8.1]
  def up
    drop_table :action_text_rich_texts
    remove_column :posts, :body
  end

  def down
    add_column :posts, :body, :text
    create_table :action_text_rich_texts do |t|
      t.string :name, null: false
      t.text :body
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.timestamps
      t.index %i[record_type record_id name], name: 'index_action_text_rich_texts_uniqueness', unique: true
    end
  end
end
