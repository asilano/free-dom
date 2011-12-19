class AddFactsToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :facts, :text
  end

  def self.down
    remove_column :games, :facts
  end
end
