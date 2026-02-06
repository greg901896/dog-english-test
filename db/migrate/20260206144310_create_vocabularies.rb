class CreateVocabularies < ActiveRecord::Migration[8.1]
  def change
    create_table :vocabularies do |t|
      t.string :english, null: false
      t.string :chinese, null: false
      t.string :category
      t.integer :difficulty, default: 1

      t.timestamps
    end

    add_index :vocabularies, :english, unique: true
    add_index :vocabularies, :category
  end
end
