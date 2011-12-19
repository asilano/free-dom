class AddLockToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :lock, :boolean
  end

  def self.down
    remove_column :players, :lock
  end
end
