class AddStateToPendingActions < ActiveRecord::Migration
  def change
    add_column :pending_actions, :state, :text
  end
end
