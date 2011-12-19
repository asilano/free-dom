class AddAuthToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :salt, :string
    add_column :players, :pass_hash, :string
  end

  def self.down
    remove_column :players, :pass_hash
    remove_column :players, :salt
  end
end
