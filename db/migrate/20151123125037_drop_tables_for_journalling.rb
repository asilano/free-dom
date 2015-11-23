class DropTablesForJournalling < ActiveRecord::Migration
  def change
    drop_table :cards
    drop_table :pending_actions
    drop_table :piles
    drop_table :player_states
    drop_table :histories

    remove_columns :games, :state, :facts, :turn_count, :turn_phase
    remove_columns :players, :cash, :seat, :vp_chips
  end
end
