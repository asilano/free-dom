class AddPeekedToCards < ActiveRecord::Migration
  def self.up
    add_column :cards, :peeked, :boolean
  end

  def self.down
    remove_column :cards, :peeked
  end
end
