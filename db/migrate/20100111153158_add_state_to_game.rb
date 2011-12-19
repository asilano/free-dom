class AddStateToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :state, :string, :default => "waiting"
  end

  def self.down
    remove_column :games, :state
  end
end
