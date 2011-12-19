class AddStateToCards < ActiveRecord::Migration
  def self.up
    add_column :cards, :state, :text
  end

  def self.down
    remove_column :cards, :state
  end
end
