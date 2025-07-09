class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :username, :string, null: false, default: ''
    add_column :users, :first_name, :string, default: ''
    add_column :users, :last_name, :string, default: ''

    User.reset_column_information
    User.all.each do |user|
      next if user.username.present?

      unique_username = user.email.present? ? user.email.split('@').first : "user_#{SecureRandom.hex(4)}"
      unique_username = "user_#{SecureRandom.hex(4)}" while User.exists?(username: unique_username)
      user.update_column(:username, unique_username)
    end
  end
end
