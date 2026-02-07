class AddUsernameToUsers < ActiveRecord::Migration[8.1]
  def up
    unless column_exists?(:users, :username)
      add_column :users, :username, :string
    end

    execute "UPDATE users SET username = CONCAT('user', id) WHERE username IS NULL OR username = ''"

    change_column :users, :username, :string, null: false, default: ""

    unless index_exists?(:users, :username)
      add_index :users, :username, unique: true
    end
  end

  def down
    remove_index :users, :username, if_exists: true
    remove_column :users, :username, if_exists: true
  end
end
