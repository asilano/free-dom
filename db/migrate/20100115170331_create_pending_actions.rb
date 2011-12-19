class CreatePendingActions < ActiveRecord::Migration
  def self.up
    create_table :pending_actions do |t|
      t.integer :game_id
      t.integer :parent_id
      t.integer :player_id
      t.string :expected_action

    end
  end

  def self.down
    drop_table :pending_actions
  end
end
