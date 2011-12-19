class AddStateToPiles < ActiveRecord::Migration
  def self.up
    add_column :piles, :state, :text
  end

  def self.down
    remove_column :piles, :state
  end
end
