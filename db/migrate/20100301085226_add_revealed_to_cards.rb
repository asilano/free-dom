class AddRevealedToCards < ActiveRecord::Migration
  def self.up
    add_column :cards, :revealed, :boolean, :default => false
  end

  def self.down
    remove_column :cards, :revealed
  end
end
