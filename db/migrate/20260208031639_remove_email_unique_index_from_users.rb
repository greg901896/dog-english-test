class RemoveEmailUniqueIndexFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, :email, unique: true
    change_column_default :users, :email, from: "", to: nil
    change_column_null :users, :email, true
  end
end
