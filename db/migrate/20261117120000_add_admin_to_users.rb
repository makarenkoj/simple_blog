# Admin rights move from "whoever holds AVO_EMAIL" to an explicit flag that no
# form can set. The account holding AVO_EMAIL at migration time keeps access;
# after that, the email no longer matters.
class AddAdminToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :admin, :boolean, default: false, null: false

    email = ENV.fetch('AVO_EMAIL', nil)
    execute(sanitize_sql(['UPDATE users SET admin = TRUE WHERE email = ?', email])) if email.present?
  end

  def down
    remove_column :users, :admin
  end

  private

  def sanitize_sql(args)
    ActiveRecord::Base.sanitize_sql_array(args)
  end
end
