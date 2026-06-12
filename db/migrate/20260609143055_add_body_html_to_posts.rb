class AddBodyHtmlToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :body_html, :text
  end
end
