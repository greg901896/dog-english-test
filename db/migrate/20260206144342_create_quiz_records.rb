class CreateQuizRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :vocabulary, null: false, foreign_key: true
      t.string :user_answer
      t.boolean :correct

      t.timestamps
    end
  end
end
