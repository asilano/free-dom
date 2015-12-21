class AddTableAndColumnsForJournalling < ActiveRecord::Migration
  def change
    add_column :games, :created_at, :datetime

    create_table :journals do |t|
      t.references :game, index: true
      t.references :player, index: true
      t.text :event
      t.datetime :created_at
    end
  end
end
