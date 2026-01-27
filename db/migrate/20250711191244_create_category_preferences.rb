class CreateCategoryPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :category_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
