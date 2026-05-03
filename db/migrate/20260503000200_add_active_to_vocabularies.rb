class AddActiveToVocabularies < ActiveRecord::Migration[8.1]
  def change
    add_column :vocabularies, :active, :boolean, default: true, null: false
    add_index :vocabularies, :active
  end
end
