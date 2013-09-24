class AddPlayedFoolsGoldToPlayerState < ActiveRecord::Migration
  def change
    add_column :player_states, :played_fools_gold, :boolean
  end
end
