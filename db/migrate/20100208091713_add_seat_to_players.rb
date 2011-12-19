class AddSeatToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :seat, :integer
  end

  def self.down
    remove_column :players, :seat
  end
end
