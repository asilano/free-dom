class AddUpdateIntervalToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :update_interval, :integer, :default => 60
  end

  def self.down
    remove_column :settings, :update_interval
  end
end
