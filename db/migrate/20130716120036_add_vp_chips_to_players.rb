class AddVpChipsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :vp_chips, :integer, :default => 0
  end
end
