class AddTrackToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :actions, :integer
    add_column :players, :buys, :integer
    add_column :players, :cash, :integer
  end

  def self.down
    remove_column :players, :cash
    remove_column :players, :buys
    remove_column :players, :actions
  end
end
