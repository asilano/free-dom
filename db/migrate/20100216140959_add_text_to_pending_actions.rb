class AddTextToPendingActions < ActiveRecord::Migration
  def self.up
    add_column :pending_actions, :text, :string
  end

  def self.down
    remove_column :pending_actions, :text
  end
end
