class CreateChats < ActiveRecord::Migration
  def self.up
    create_table :chats do |t|
      t.integer :game_id
      t.integer :player_id
      t.string  :non_ply_name
      t.integer :turn
      t.integer :turn_player_id
      t.text :statement

      t.timestamps
    end
  end

  def self.down
    drop_table :chats
  end
end
