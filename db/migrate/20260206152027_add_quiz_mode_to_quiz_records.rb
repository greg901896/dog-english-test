class AddQuizModeToQuizRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :quiz_records, :quiz_mode, :string, default: "input", null: false
  end
end
