class CreatePlayerStates < ActiveRecord::Migration
  def self.up
    create_table :player_states do |t|
      t.integer :player_id
      t.boolean :outpost_queued, :default => false
      t.boolean :outpost_prevent, :default => false
      t.integer :pirate_coins, :default => 0
      t.text :gained_last_turn
      t.boolean :bought_victory, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :player_states
  end
end
