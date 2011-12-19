class AddScoreToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :score, :integer
  end

  def self.down
    remove_column :players, :score
  end
end
