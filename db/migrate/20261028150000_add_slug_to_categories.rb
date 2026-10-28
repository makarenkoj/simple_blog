class AddSlugToCategories < ActiveRecord::Migration[8.0]
  def up
    add_column :categories, :slug, :string
    add_index :categories, :slug, unique: true

    Category.reset_column_information
    Category.find_each do |category|
      category.send(:set_slug)
      category.save!(validate: false)
    end
  end

  def down
    remove_index :categories, :slug
    remove_column :categories, :slug
  end
end
