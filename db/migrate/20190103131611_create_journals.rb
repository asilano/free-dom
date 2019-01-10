class CreateJournals < ActiveRecord::Migration[5.1]
  def change
    create_table :journals do |t|
      t.references :game, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :order
      t.string :type
      t.text :params

      t.timestamps
    end
  end
end
