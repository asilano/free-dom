class AddTurnCountToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :turn_count, :integer
  end

  def self.down
    remove_column :games, :turn_count
  end
end
