class EnhancementsForPbem < ActiveRecord::Migration
  def self.up
    add_column :users, :pbem, :boolean, :default => false
    add_column :players, :last_emailed, :timestamp, :default => Time.parse("2011-01-01 00:00")
    add_column :pending_actions, :emailed, :boolean, :default => false
  end

  def self.down
    remove_column :users, :pbem
    remove_column :players, :last_emailed
    remove_column :pending_actions, :emailed
  end
end
