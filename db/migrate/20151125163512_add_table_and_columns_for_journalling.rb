class AddTableAndColumnsForJournalling < ActiveRecord::Migration
  def change
    add_column :games, :created_at, :datetime

    create_table :journals do |t|
      t.integer :game_id, index: true
      t.integer :player_id, index: true
      t.text :event
      t.datetime :created_at
    end
  end
end
