class AddCrossroadsToPlayerState < ActiveRecord::Migration
  def change
    add_column :player_states, :played_crossroads, :boolean, :default => false
  end
end
