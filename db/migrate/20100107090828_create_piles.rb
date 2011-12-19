class CreatePiles < ActiveRecord::Migration
  def self.up
    create_table :piles do |t|
      t.integer :game_id
      t.string :card_type
    end
    
    add_index :piles, [:game_id, :card_type], :unique => true
  end

  def self.down
    drop_table :piles
  end
end
