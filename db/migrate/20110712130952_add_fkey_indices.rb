class AddFkeyIndices < ActiveRecord::Migration
  def self.up
    add_index :cards, :player_id
    add_index :cards, :game_id
    add_index :cards, :pile_id
    
    add_index :pending_actions, :player_id
    add_index :pending_actions, :game_id
  end

  def self.down
    remove_index :cards, :player_id
    remove_index :cards, :game_id
    remove_index :cards, :pile_id
    
    remove_index :pending_actions, :player_id
    remove_index :pending_actions, :game_id
  end
end
