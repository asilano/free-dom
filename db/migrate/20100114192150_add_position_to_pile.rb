class AddPositionToPile < ActiveRecord::Migration
  def self.up
    add_column :piles, :position, :integer
  end

  def self.down
    remove_column :piles, :position
  end
end
