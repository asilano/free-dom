class DropActionsAndBuysFromPlayers < ActiveRecord::Migration
  def up
    remove_column :players, :actions
    remove_column :players, :buys
  end

  def down
    add_column :players, :actions, :integer
    add_column :players, :buys, :integer
  end
end
