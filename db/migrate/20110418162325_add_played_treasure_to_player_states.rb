class AddPlayedTreasureToPlayerStates < ActiveRecord::Migration
  def self.up
    add_column :player_states, :played_treasure, :boolean
  end

  def self.down
    remove_column :player_states, :played_treasure
  end
end
